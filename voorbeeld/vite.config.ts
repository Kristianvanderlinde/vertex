import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

// Voorbeeldpagina van het ontwerpsysteem: npm run voorbeeld → http://localhost:5191
export default defineConfig({
	plugins: [svelte()],
	server: { fs: { allow: ['..'] } }
});
