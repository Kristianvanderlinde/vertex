<!-- Chip. Toon bepaalt de kleur. Met onclick wordt het een knop (bijvoorbeeld om een filter weg te halen). -->
<script lang="ts">
	import type { Snippet } from 'svelte';

	type Props = {
		toon?: 'accent' | 'positief' | 'waarschuwing' | 'neutraal' | 'negatief';
		onclick?: (e: MouseEvent) => void;
		titel?: string;
		children: Snippet;
	};
	let { toon = 'neutraal', onclick, titel, children }: Props = $props();
</script>

{#if onclick}
	<button type="button" class="chip {toon}" {onclick} title={titel}>{@render children()}</button>
{:else}
	<span class="chip {toon}" title={titel}>{@render children()}</span>
{/if}

<style>
	.chip {
		all: unset;
		box-sizing: border-box;
		display: inline-flex;
		align-items: center;
		gap: 5px;
		padding: 4px 12px;
		border-radius: var(--vorm-pill);
		font: 600 12px/16px var(--tekst-familie);
		white-space: nowrap;
		max-width: 100%;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	button.chip {
		cursor: pointer;
	}
	button.chip:focus-visible {
		outline: 2px solid var(--accent-standaard);
		outline-offset: 2px;
	}
	.accent {
		background: var(--accent-zacht);
		color: var(--accent-standaard);
	}
	.positief {
		background: var(--status-positief-zacht);
		color: var(--status-positief);
	}
	.waarschuwing {
		background: var(--status-waarschuwing-zacht);
		color: var(--status-waarschuwing);
	}
	.neutraal {
		background: var(--achtergrond-vlak);
		color: var(--tekst-gedempt);
	}
	.negatief {
		background: var(--status-negatief-zacht);
		color: var(--status-negatief);
	}
</style>
