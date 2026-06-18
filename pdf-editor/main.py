"""
PDF Editor for Windows — read, annotate, and export PDFs.
"""

from __future__ import annotations

import io
import os
import sys
import tkinter as tk
from tkinter import colorchooser, filedialog, messagebox, simpledialog, ttk

import fitz  # PyMuPDF
from PIL import Image, ImageTk


APP_TITLE = "PDF Editor"
DEFAULT_ZOOM = 1.25
MIN_ZOOM = 0.4
MAX_ZOOM = 4.0
ZOOM_STEP = 0.15


class PDFEditorApp:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title(APP_TITLE)
        self.root.geometry("1200x800")
        self.root.minsize(900, 600)

        self.doc: fitz.Document | None = None
        self.file_path: str | None = None
        self.modified = False
        self.current_page = 0
        self.zoom = DEFAULT_ZOOM
        self.tool = "select"
        self.text_color = (0, 0, 0)
        self.font_size = 14
        self.highlight_color = (1, 1, 0)
        self._photo: ImageTk.PhotoImage | None = None
        self._drag_start: tuple[float, float] | None = None
        self._drag_rect_id: int | None = None

        self._build_ui()
        self._bind_shortcuts()
        self._update_title()
        self._set_status("Open a PDF file to begin.")

    # ------------------------------------------------------------------ UI
    def _build_ui(self) -> None:
        self._build_menu()
        self._build_toolbar()

        paned = ttk.Panedwindow(self.root, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True)

        sidebar = ttk.Frame(paned, width=180)
        self._build_sidebar(sidebar)
        paned.add(sidebar, weight=0)

        viewer_frame = ttk.Frame(paned)
        paned.add(viewer_frame, weight=1)

        self.canvas = tk.Canvas(viewer_frame, bg="#525659", highlightthickness=0)
        v_scroll = ttk.Scrollbar(viewer_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        h_scroll = ttk.Scrollbar(viewer_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        self.canvas.configure(yscrollcommand=v_scroll.set, xscrollcommand=h_scroll.set)

        v_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        h_scroll.pack(side=tk.BOTTOM, fill=tk.X)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.canvas.bind("<ButtonPress-1>", self._on_canvas_press)
        self.canvas.bind("<B1-Motion>", self._on_canvas_drag)
        self.canvas.bind("<ButtonRelease-1>", self._on_canvas_release)
        self.canvas.bind("<MouseWheel>", self._on_mousewheel)
        self.canvas.bind("<Control-MouseWheel>", self._on_ctrl_mousewheel)

        status = ttk.Frame(self.root)
        status.pack(fill=tk.X, side=tk.BOTTOM)
        self.status_var = tk.StringVar()
        ttk.Label(status, textvariable=self.status_var, anchor=tk.W).pack(
            fill=tk.X, padx=8, pady=4
        )

    def _build_menu(self) -> None:
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Open...", accelerator="Ctrl+O", command=self.open_file)
        file_menu.add_command(label="Save", accelerator="Ctrl+S", command=self.save_file)
        file_menu.add_command(label="Save As...", accelerator="Ctrl+Shift+S", command=self.save_as)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)

        edit_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Add Text", command=lambda: self._set_tool("text"))
        edit_menu.add_command(label="Highlight", command=lambda: self._set_tool("highlight"))
        edit_menu.add_command(label="Draw Rectangle", command=lambda: self._set_tool("rect"))
        edit_menu.add_command(label="Erase Annotations on Page", command=self.erase_page_annotations)

        page_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Page", menu=page_menu)
        page_menu.add_command(label="Previous Page", accelerator="PgUp", command=self.prev_page)
        page_menu.add_command(label="Next Page", accelerator="PgDn", command=self.next_page)
        page_menu.add_separator()
        page_menu.add_command(label="Rotate Left", command=lambda: self.rotate_page(-90))
        page_menu.add_command(label="Rotate Right", command=lambda: self.rotate_page(90))
        page_menu.add_command(label="Add Blank Page After", command=self.add_blank_page)
        page_menu.add_command(label="Delete Current Page", command=self.delete_page)

        view_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="Zoom In", accelerator="Ctrl++", command=self.zoom_in)
        view_menu.add_command(label="Zoom Out", accelerator="Ctrl+-", command=self.zoom_out)
        view_menu.add_command(label="Reset Zoom", command=self.reset_zoom)

        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)

    def _build_toolbar(self) -> None:
        bar = ttk.Frame(self.root, padding=(4, 4))
        bar.pack(fill=tk.X)

        ttk.Button(bar, text="Open", command=self.open_file).pack(side=tk.LEFT, padx=2)
        ttk.Button(bar, text="Save", command=self.save_file).pack(side=tk.LEFT, padx=2)

        ttk.Separator(bar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=6)

        ttk.Button(bar, text="◀ Prev", command=self.prev_page).pack(side=tk.LEFT, padx=2)
        self.page_label = ttk.Label(bar, text="Page — / —", width=16, anchor=tk.CENTER)
        self.page_label.pack(side=tk.LEFT, padx=4)
        ttk.Button(bar, text="Next ▶", command=self.next_page).pack(side=tk.LEFT, padx=2)

        ttk.Separator(bar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=6)

        ttk.Button(bar, text="Zoom −", command=self.zoom_out).pack(side=tk.LEFT, padx=2)
        self.zoom_label = ttk.Label(bar, text=f"{int(self.zoom * 100)}%")
        self.zoom_label.pack(side=tk.LEFT, padx=4)
        ttk.Button(bar, text="Zoom +", command=self.zoom_in).pack(side=tk.LEFT, padx=2)

        ttk.Separator(bar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=6)

        self.tool_var = tk.StringVar(value="select")
        for label, value in [
            ("Select", "select"),
            ("Text", "text"),
            ("Highlight", "highlight"),
            ("Rectangle", "rect"),
        ]:
            ttk.Radiobutton(
                bar, text=label, value=value, variable=self.tool_var, command=self._on_tool_change
            ).pack(side=tk.LEFT, padx=2)

    def _build_sidebar(self, parent: ttk.Frame) -> None:
        ttk.Label(parent, text="Tools", font=("Segoe UI", 10, "bold")).pack(anchor=tk.W, padx=8, pady=(8, 4))

        ttk.Label(parent, text="Font size").pack(anchor=tk.W, padx=8)
        self.font_spin = ttk.Spinbox(parent, from_=6, to=72, width=8, command=self._read_font_size)
        self.font_spin.set(self.font_size)
        self.font_spin.pack(anchor=tk.W, padx=8, pady=(0, 8))
        self.font_spin.bind("<Return>", lambda _e: self._read_font_size())

        ttk.Button(parent, text="Text Color...", command=self.pick_text_color).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )
        ttk.Button(parent, text="Highlight Color...", command=self.pick_highlight_color).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )

        ttk.Separator(parent).pack(fill=tk.X, padx=8, pady=10)

        ttk.Label(parent, text="Page actions", font=("Segoe UI", 10, "bold")).pack(
            anchor=tk.W, padx=8, pady=(0, 4)
        )
        ttk.Button(parent, text="Rotate Left", command=lambda: self.rotate_page(-90)).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )
        ttk.Button(parent, text="Rotate Right", command=lambda: self.rotate_page(90)).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )
        ttk.Button(parent, text="Add Blank Page", command=self.add_blank_page).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )
        ttk.Button(parent, text="Delete Page", command=self.delete_page).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )
        ttk.Button(parent, text="Clear Annotations", command=self.erase_page_annotations).pack(
            anchor=tk.W, padx=8, pady=2, fill=tk.X
        )

    def _bind_shortcuts(self) -> None:
        self.root.bind("<Control-o>", lambda _e: self.open_file())
        self.root.bind("<Control-s>", lambda _e: self.save_file())
        self.root.bind("<Control-S>", lambda _e: self.save_as())
        self.root.bind("<Prior>", lambda _e: self.prev_page())
        self.root.bind("<Next>", lambda _e: self.next_page())
        self.root.bind("<Control-plus>", lambda _e: self.zoom_in())
        self.root.bind("<Control-equal>", lambda _e: self.zoom_in())
        self.root.bind("<Control-minus>", lambda _e: self.zoom_out())

    # -------------------------------------------------------------- helpers
    def _set_status(self, message: str) -> None:
        self.status_var.set(message)

    def _update_title(self) -> None:
        name = os.path.basename(self.file_path) if self.file_path else "Untitled"
        modified = " *" if self.modified else ""
        self.root.title(f"{name}{modified} — {APP_TITLE}")

    def _set_tool(self, tool: str) -> None:
        self.tool_var.set(tool)
        self.tool = tool
        self._set_status(f"Tool: {tool.capitalize()}")

    def _on_tool_change(self) -> None:
        self.tool = self.tool_var.get()
        self._set_status(f"Tool: {self.tool.capitalize()}")

    def _read_font_size(self) -> None:
        try:
            self.font_size = int(self.font_spin.get())
        except ValueError:
            self.font_spin.set(self.font_size)

    def _require_doc(self) -> bool:
        if self.doc is None:
            messagebox.showinfo(APP_TITLE, "Open a PDF file first.")
            return False
        return True

    def _canvas_to_pdf(self, canvas_x: float, canvas_y: float) -> tuple[float, float]:
        """Convert canvas coordinates to PDF page coordinates."""
        page = self.doc[self.current_page]
        mat = fitz.Matrix(self.zoom, self.zoom)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        page_w, page_h = pix.width, pix.height
        canvas_w = self.canvas.winfo_width()
        canvas_h = self.canvas.winfo_height()
        offset_x = max((canvas_w - page_w) / 2, 0)
        offset_y = max((canvas_h - page_h) / 2, 0)
        pdf_x = (canvas_x - offset_x) / self.zoom
        pdf_y = (canvas_y - offset_y) / self.zoom
        return pdf_x, pdf_y

    def _mark_modified(self) -> None:
        self.modified = True
        self._update_title()

    # ----------------------------------------------------------- file I/O
    def open_file(self) -> None:
        path = filedialog.askopenfilename(
            title="Open PDF",
            filetypes=[("PDF files", "*.pdf"), ("All files", "*.*")],
        )
        if not path:
            return
        try:
            doc = fitz.open(path)
        except Exception as exc:
            messagebox.showerror(APP_TITLE, f"Could not open PDF:\n{exc}")
            return

        if self.doc is not None:
            self.doc.close()
        self.doc = doc
        self.file_path = path
        self.modified = False
        self.current_page = 0
        self._update_title()
        self.render_page()
        self._set_status(f"Opened {os.path.basename(path)}")

    def save_file(self) -> None:
        if not self._require_doc():
            return
        if not self.file_path:
            self.save_as()
            return
        self._write_pdf(self.file_path)

    def save_as(self) -> None:
        if not self._require_doc():
            return
        path = filedialog.asksaveasfilename(
            title="Save PDF As",
            defaultextension=".pdf",
            filetypes=[("PDF files", "*.pdf")],
        )
        if not path:
            return
        self._write_pdf(path)
        self.file_path = path
        self._update_title()

    def _write_pdf(self, path: str) -> None:
        assert self.doc is not None
        try:
            if path.lower().endswith(".pdf"):
                self.doc.save(path, garbage=4, deflate=True)
            else:
                self.doc.save(path + ".pdf", garbage=4, deflate=True)
            self.modified = False
            self._update_title()
            self._set_status(f"Saved to {os.path.basename(path)}")
        except Exception as exc:
            messagebox.showerror(APP_TITLE, f"Could not save PDF:\n{exc}")

    # --------------------------------------------------------- rendering
    def render_page(self) -> None:
        if self.doc is None:
            return

        page = self.doc[self.current_page]
        mat = fitz.Matrix(self.zoom, self.zoom)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        img = Image.open(io.BytesIO(pix.tobytes("ppm")))
        self._photo = ImageTk.PhotoImage(img)

        self.canvas.delete("all")
        canvas_w = max(self.canvas.winfo_width(), 1)
        canvas_h = max(self.canvas.winfo_height(), 1)
        offset_x = max((canvas_w - pix.width) / 2, 0)
        offset_y = max((canvas_h - pix.height) / 2, 0)

        self.canvas.create_image(offset_x, offset_y, anchor=tk.NW, image=self._photo, tags="page")
        self.canvas.config(scrollregion=(0, 0, max(canvas_w, pix.width), max(canvas_h, pix.height)))

        total = len(self.doc)
        self.page_label.config(text=f"Page {self.current_page + 1} / {total}")
        self.zoom_label.config(text=f"{int(self.zoom * 100)}%")
        self._set_status(f"Viewing page {self.current_page + 1} of {total}")

    def prev_page(self) -> None:
        if not self._require_doc() or self.current_page <= 0:
            return
        self.current_page -= 1
        self.render_page()

    def next_page(self) -> None:
        if not self._require_doc() or self.current_page >= len(self.doc) - 1:
            return
        self.current_page += 1
        self.render_page()

    def zoom_in(self) -> None:
        self.zoom = min(self.zoom + ZOOM_STEP, MAX_ZOOM)
        self.render_page()

    def zoom_out(self) -> None:
        self.zoom = max(self.zoom - ZOOM_STEP, MIN_ZOOM)
        self.render_page()

    def reset_zoom(self) -> None:
        self.zoom = DEFAULT_ZOOM
        self.render_page()

    def _on_mousewheel(self, event: tk.Event) -> None:
        self.canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    def _on_ctrl_mousewheel(self, event: tk.Event) -> None:
        if event.delta > 0:
            self.zoom_in()
        else:
            self.zoom_out()

    # ---------------------------------------------------------- editing
    def _on_canvas_press(self, event: tk.Event) -> None:
        if not self._require_doc():
            return
        self._drag_start = (event.x, event.y)
        if self.tool in ("highlight", "rect"):
            self._drag_rect_id = self.canvas.create_rectangle(
                event.x, event.y, event.x, event.y, outline="#ff9800", width=2, dash=(4, 4)
            )

    def _on_canvas_drag(self, event: tk.Event) -> None:
        if self._drag_start is None or self._drag_rect_id is None:
            return
        x0, y0 = self._drag_start
        self.canvas.coords(self._drag_rect_id, x0, y0, event.x, event.y)

    def _on_canvas_release(self, event: tk.Event) -> None:
        if not self._require_doc() or self._drag_start is None:
            return

        x0, y0 = self._drag_start
        x1, y1 = event.x, event.y
        self._drag_start = None

        if self._drag_rect_id is not None:
            self.canvas.delete(self._drag_rect_id)
            self._drag_rect_id = None

        if self.tool == "text":
            self._add_text_at(x1, y1)
        elif self.tool == "highlight" and abs(x1 - x0) > 4 and abs(y1 - y0) > 4:
            self._add_highlight(x0, y0, x1, y1)
        elif self.tool == "rect" and abs(x1 - x0) > 4 and abs(y1 - y0) > 4:
            self._add_rectangle(x0, y0, x1, y1)

    def _add_text_at(self, canvas_x: float, canvas_y: float) -> None:
        assert self.doc is not None
        text = simpledialog.askstring("Add Text", "Enter text:", parent=self.root)
        if not text:
            return

        pdf_x, pdf_y = self._canvas_to_pdf(canvas_x, canvas_y)
        page = self.doc[self.current_page]
        page.insert_text(
            (pdf_x, pdf_y),
            text,
            fontsize=self.font_size,
            color=self.text_color,
        )
        self._mark_modified()
        self.render_page()
        self._set_status("Text added.")

    def _add_highlight(self, cx0: float, cy0: float, cx1: float, cy1: float) -> None:
        assert self.doc is not None
        x0, y0 = self._canvas_to_pdf(cx0, cy0)
        x1, y1 = self._canvas_to_pdf(cx1, cy1)
        rect = fitz.Rect(min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1))
        page = self.doc[self.current_page]
        annot = page.add_highlight_annot(rect)
        if annot:
            annot.set_colors(stroke=self.highlight_color)
            annot.update()
        self._mark_modified()
        self.render_page()
        self._set_status("Highlight added.")

    def _add_rectangle(self, cx0: float, cy0: float, cx1: float, cy1: float) -> None:
        assert self.doc is not None
        x0, y0 = self._canvas_to_pdf(cx0, cy0)
        x1, y1 = self._canvas_to_pdf(cx1, cy1)
        rect = fitz.Rect(min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1))
        page = self.doc[self.current_page]
        annot = page.add_rect_annot(rect)
        if annot:
            annot.set_border(width=1)
            annot.set_colors(stroke=(1, 0, 0))
            annot.update()
        self._mark_modified()
        self.render_page()
        self._set_status("Rectangle annotation added.")

    def erase_page_annotations(self) -> None:
        if not self._require_doc():
            return
        if not messagebox.askyesno(APP_TITLE, "Remove all annotations on the current page?"):
            return
        page = self.doc[self.current_page]
        for annot in list(page.annots() or []):
            page.delete_annot(annot)
        self._mark_modified()
        self.render_page()
        self._set_status("Annotations cleared on current page.")

    def rotate_page(self, degrees: int) -> None:
        if not self._require_doc():
            return
        page = self.doc[self.current_page]
        page.set_rotation((page.rotation + degrees) % 360)
        self._mark_modified()
        self.render_page()
        self._set_status(f"Page rotated {degrees}°.")

    def add_blank_page(self) -> None:
        if not self._require_doc():
            return
        page = self.doc[self.current_page]
        self.doc.new_page(self.current_page + 1, width=page.rect.width, height=page.rect.height)
        self.current_page += 1
        self._mark_modified()
        self.render_page()
        self._set_status("Blank page inserted.")

    def delete_page(self) -> None:
        if not self._require_doc():
            return
        if len(self.doc) <= 1:
            messagebox.showwarning(APP_TITLE, "Cannot delete the only page in the document.")
            return
        if not messagebox.askyesno(APP_TITLE, "Delete the current page?"):
            return
        self.doc.delete_page(self.current_page)
        self.current_page = min(self.current_page, len(self.doc) - 1)
        self._mark_modified()
        self.render_page()
        self._set_status("Page deleted.")

    def pick_text_color(self) -> None:
        rgb, _hex = colorchooser.askcolor(title="Text color")
        if rgb:
            self.text_color = tuple(c / 255 for c in rgb)

    def pick_highlight_color(self) -> None:
        rgb, _hex = colorchooser.askcolor(title="Highlight color")
        if rgb:
            self.highlight_color = tuple(c / 255 for c in rgb)

    def show_about(self) -> None:
        messagebox.showinfo(
            APP_TITLE,
            "PDF Editor for Windows\n\n"
            "Open, view, annotate, and save PDF files.\n\n"
            "Tools: text, highlight, rectangles, page rotate/delete/add.",
        )


def main() -> None:
    root = tk.Tk()
    try:
        root.iconbitmap(default="")
    except tk.TclError:
        pass
    app = PDFEditorApp(root)
    root.after(100, app.render_page)
    root.mainloop()


if __name__ == "__main__":
    main()
