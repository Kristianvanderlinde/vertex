<!-- Terugknop: alleen pijltje en label in accentkleur, zonder achtergrond of padding, bijvoorbeeld "‹ Instellingen". -->
<script lang="ts">
	import type { Snippet } from 'svelte';

	let { href, children }: { href: string; children: Snippet } = $props();
</script>

<a class="terugknop" {href}>
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 6 8.5 12l6 6" /></svg>
	{@render children()}
</a>

<style>
	.terugknop {
		display: inline-flex;
		align-items: center;
		gap: 2px;
		margin-left: -4px;
		color: var(--accent-standaard);
		font: 600 15px/22px var(--tekst-familie, inherit);
		text-decoration: none;
	}
	.terugknop:hover {
		opacity: 0.75;
	}
	.terugknop:focus-visible {
		outline: 2px solid var(--accent-standaard);
		outline-offset: 2px;
		border-radius: 6px;
	}
</style>
