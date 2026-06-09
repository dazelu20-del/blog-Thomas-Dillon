const posts = [
  {
    id: "writing-heals",
    title: "글쓰기가 마음을 치유하는 이유",
    excerpt: "매일 조금씩 글을 쓰면 생각이 정리되고, 나 자신과의 대화가 시작됩니다.",
    tag: "마음챙김",
    date: "2026년 6월 9일",
    author: "김서연",
    content: `
      <p>하루가 끝나면 머릿속은 여전히 복잡합니다. 읽지 않은 메시지, 내일 해야 할 일, 문득 떠오른 후회까지. 잠들기 전 스마트폰을 내려놓아도, 생각은 멈추지 않습니다.</p>
      <p>그런데 노트에 몇 줄만 적어 보면 이상하게 마음이 가벼워집니다. 완벽한 문장이 아니어도 괜찮습니다. 오늘 무엇이 힘들었는지, 무엇이 고마웠는지, 내일은 무엇을 바라는지—솔직하게 적는 것만으로도 충분합니다.</p>
      <h2>글쓰기가 주는 세 가지 선물</h2>
      <p><strong>생각이 정리됩니다.</strong> 머릿속에서 맴도는 감정을 글로 옮기면, 흩어진 생각이 하나의 이야기로 엮입니다. 문제의 크기도 더 정확하게 보이게 됩니다.</p>
      <p><strong>나를 더 잘 알게 됩니다.</strong> 일기를 쓰다 보면 반복되는 패턴이 보입니다. 어떤 상황에서 기분이 나빠지는지, 무엇에 에너지가 생기는지. 타인의 시선이 아닌, 내 목소리로 나를 이해하게 됩니다.</p>
      <p><strong>작은 성취감이 쌓입니다.</strong> 하루에 문단 하나, 혹은 다섯 문장. 거창한 소설이 아니어도 됩니다. 꾸준히 쓴다는 사실 자체가 '나는 오늘도 나를 위해 시간을 썼다'는 기록이 됩니다.</p>
      <h2>오늘부터 시작하는 방법</h2>
      <p>매일 같은 시간에 10분만 비워 보세요. 아침 커피 한 잔 전, 혹은 잠들기 직전. 주제를 정하지 않아도 됩니다. "오늘 가장 기억에 남는 순간은?"이라는 질문 하나로 시작해 보세요.</p>
      <p>남들이 읽을 글이 아니어도 괜찮습니다. 이 글은 오직 나를 위한 것입니다. 맞춤법이 틀려도, 문장이 어색해도, 괜찮습니다. 중요한 것은 솔직함입니다.</p>
      <blockquote>글은 생각을 담는 그릇이 아니라, 생각이 스스로 정리되게 만드는 도구입니다.</blockquote>
      <p>바쁜 세상 속에서 잠시 멈추고, 나에게 말을 걸어 보세요. 그 짧은 대화가 하루를, 그리고 결국 삶을 조금 더 따뜻하게 만들어 줄 것입니다.</p>
    `
  },
  {
    id: "getting-started",
    title: "Getting Started with Your Blog",
    excerpt: "Every great blog begins with a single post. Here's how to make yours shine from day one.",
    tag: "Guide",
    date: "June 1, 2026",
    author: "Alex Rivera",
    content: `
      <p>Starting a blog can feel overwhelming, but it doesn't have to be. The best blogs are built on consistency, authenticity, and a genuine desire to share something useful with the world.</p>
      <p>Before you write your first post, ask yourself: <em>What do I want to say, and who am I saying it for?</em> That clarity will guide every word you publish.</p>
      <h2>Three principles for great blogging</h2>
      <p><strong>Write for one person.</strong> Don't try to please everyone. Pick your ideal reader and write directly to them.</p>
      <p><strong>Publish before you're ready.</strong> Perfection is the enemy of progress. Ship your first post, then improve with each one.</p>
      <p><strong>Be consistent.</strong> A post every two weeks beats a burst of five posts followed by months of silence.</p>
      <blockquote>The scariest moment is always just before you start. After that, things usually get better.</blockquote>
      <p>Now go write something. The world is waiting to hear your voice.</p>
    `
  },
  {
    id: "morning-routine",
    title: "The Power of a Morning Routine",
    excerpt: "How a simple 30-minute morning ritual transformed my productivity and mindset.",
    tag: "Lifestyle",
    date: "May 28, 2026",
    author: "Alex Rivera",
    content: `
      <p>For years, I rolled out of bed and straight into my inbox. Emails dictated my morning, and by 10 AM I felt like I'd already lost the day. Then I tried something different.</p>
      <h2>My current morning routine</h2>
      <p><strong>6:00 AM</strong> — Wake up, drink a glass of water, no phone for the first 30 minutes.</p>
      <p><strong>6:10 AM</strong> — 10 minutes of stretching or a short walk outside.</p>
      <p><strong>6:20 AM</strong> — Journal three things I'm grateful for and one intention for the day.</p>
      <p><strong>6:30 AM</strong> — Coffee and 20 minutes of reading — not news, not social media, just a book.</p>
      <p>That's it. Nothing elaborate. But those 30 minutes set a tone that carries through everything else.</p>
      <blockquote>How you start your morning is how you start your life.</blockquote>
      <p>You don't need to copy my routine. Build one that fits your life. The key is protecting that first hour from the noise of the world.</p>
    `
  },
  {
    id: "learning-to-code",
    title: "Learning to Code in 2026",
    excerpt: "The landscape has changed. Here's an honest guide to picking up programming today.",
    tag: "Tech",
    date: "May 20, 2026",
    author: "Alex Rivera",
    content: `
      <p>When I learned to code a decade ago, the path was linear: HTML, CSS, JavaScript, then a framework. Today, AI tools, no-code platforms, and an explosion of languages make the entry point feel chaotic.</p>
      <h2>Start with problems, not languages</h2>
      <p>Instead of asking "What language should I learn?", ask "What do I want to build?" A personal website? A data dashboard? A mobile app? Your project determines your stack.</p>
      <h2>Recommended starting points</h2>
      <p><strong>Web development:</strong> HTML, CSS, and JavaScript remain the foundation. Learn them in a browser — no setup required.</p>
      <p><strong>Automation &amp; scripting:</strong> Python is still the most approachable general-purpose language.</p>
      <p><strong>Data &amp; analysis:</strong> SQL plus a spreadsheet tool will take you surprisingly far.</p>
      <p>Use AI assistants as tutors, not crutches. Ask them to explain code you don't understand, suggest exercises, and review your work — but always type the code yourself.</p>
      <blockquote>The best time to start was yesterday. The second best time is today.</blockquote>
    `
  },
  {
    id: "slow-living",
    title: "Embracing Slow Living",
    excerpt: "In a world obsessed with speed, choosing to move deliberately is a radical act.",
    tag: "Mindfulness",
    date: "May 12, 2026",
    author: "Alex Rivera",
    content: `
      <p>We live in an age of instant everything — instant messages, instant delivery, instant gratification. Somewhere along the way, we forgot that some of the best things in life take time.</p>
      <p>Slow living isn't about being lazy. It's about being intentional. It's cooking a meal from scratch instead of ordering takeout. It's reading a physical book instead of skimming headlines. It's taking a walk without a destination.</p>
      <h2>Small shifts that make a difference</h2>
      <p>Turn off non-essential notifications. Eat one meal a day without screens. Schedule unstructured time on your calendar. Say no to things that don't align with your values.</p>
      <blockquote>Nature does not hurry, yet everything is accomplished.</blockquote>
      <p>You don't have to overhaul your life overnight. Pick one area and slow down. Notice how it feels. Then expand from there.</p>
    `
  }
];

function getPostById(id) {
  return posts.find(post => post.id === id);
}

function formatDate(dateStr) {
  return dateStr;
}
