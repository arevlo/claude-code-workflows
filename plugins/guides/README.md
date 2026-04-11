# Frontend Guides

Frontend development reference guides -- React patterns, Next.js performance, React Native best practices, and Web Interface Guidelines.

These are **skills** (reference material), not slash commands. They trigger automatically when Claude detects relevant context in your task.

## Installation

```bash
/plugin marketplace add arevlo/claude-code-workflows
/plugin install guides@claude-code-workflows
```

## What's Included

### Skills

| Skill | Triggers On | Source |
|-------|-------------|--------|
| `composition-patterns` | Refactoring components with boolean prop proliferation, compound components, context providers, component architecture | Vercel Engineering |
| `react-best-practices` | Writing/reviewing React or Next.js code, data fetching, bundle optimization, performance improvements | Vercel Engineering |
| `react-native` | Building React Native/Expo components, list performance, animations, native modules | Vercel Engineering |
| `web-design-guidelines` | UI review, accessibility audit, design compliance checks | Vercel Labs |

## How It Works

Skills are loaded as context when Claude determines they are relevant to the current task. For example:

- Working on a React component with many boolean props? `composition-patterns` activates with compound component patterns.
- Optimizing a Next.js page load? `react-best-practices` provides waterfall elimination and bundle size rules.
- Building a FlashList in React Native? `react-native` provides list performance best practices.
- Running `/web-design-guidelines src/components/` reviews files against Web Interface Guidelines.

## License

MIT -- skills authored by Vercel Engineering and Vercel Labs.
