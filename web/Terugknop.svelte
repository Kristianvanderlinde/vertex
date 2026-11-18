<!-- Terugknop: een doorzichtige (tertiaire) knop met pijltje, bijvoorbeeld "‹ Instellingen". -->
<script lang="ts">
	import type { Snippet } from 'svelte';
	import Knop from './Knop.svelte';

	let { href, children }: { href: string; children: Snippet } = $props();
</script>

{#snippet pijl()}
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 6 8.5 12l6 6" /></svg>
{/snippet}

<Knop {href} variant="tertiair" maat="s" icoon={pijl} class="terugknop">{@render children()}</Knop>

<style>
	/* Iets naar links, zodat het pijltje op de rand van de inhoud uitkomt. */
	:global(.terugknop) {
		margin-left: calc(var(--ruimte-2) * -1);
		padding-left: var(--ruimte-2) !important;
		padding-right: var(--ruimte-3) !important;
		gap: 2px !important;
		min-height: 36px !important;
		font-size: 15px !important;
		line-height: 22px !important;
	}
</style>
