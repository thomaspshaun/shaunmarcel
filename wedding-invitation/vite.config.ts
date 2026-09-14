import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [tailwindcss(), sveltekit()],
  server: {
    watch: {
      // Avoid crashes from Visual Studio's hidden solution/index folder on Windows.
      ignored: ['**/.vs/**']
    }
  }
});
