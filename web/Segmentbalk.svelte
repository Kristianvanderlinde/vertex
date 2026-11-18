<!-- Segmentbalk: één keuze uit een paar opties, met optioneel een teller per optie. -->
<script lang="ts">
	type Optie = { waarde: string; label: string; teller?: number | string | null };
	type Props = {
		opties: Optie[];
		waarde: string;
		onkies?: (waarde: string) => void;
		/** Gradient voor gebruik op een paarse kaart. */
		achtergrond?: 'standaard' | 'gradient';
		label?: string;
		/** Alle opties even breed over de volle breedte. */
		vol?: boolean;
	};
	let { opties, waarde = $bindable(), onkies, achtergrond = 'standaard', label, vol = false }: Props = $props();
</script>

<div class="balk {achtergrond}" class:vol role="group" aria-label={label}>
	{#each opties as o (o.waarde)}
		<button type="button" class="optie" class:actief={waarde === o.waarde} aria-pressed={waarde === o.waarde} onclick={() => { waarde = o.waarde; onkies?.(o.waarde); }}>
			{o.label}
			{#if o.teller != null && o.teller !== ''}<span class="teller">{o.teller}</span>{/if}
		</button>
	{/each}
</div>

<style>
	.balk {
		display: inline-flex;
		padding: 4px;
		gap: 0;
		background: var(--achtergrond-spoor);
		border: 1px solid var(--lijn-standaard);
		border-radius: 14px;
	}
	.balk.vol {
		display: flex;
	}
	.optie {
		all: unset;
		box-sizing: border-box;
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 6px;
		padding: 8px 14px;
		border-radius: 10px;
		font: 600 15px/22px var(--tekst-familie);
		color: var(--tekst-gedempt);
		cursor: pointer;
		white-space: nowrap;
		transition:
			background-color 0.15s,
			color 0.15s;
	}
	.vol .optie {
		flex: 1;
	}
	.optie:focus-visible {
		outline: 2px solid var(--accent-standaard);
		outline-offset: 1px;
	}
	.actief {
		background: var(--hoogte-2-vlak);
		box-shadow: var(--schaduw-hoogte-2);
		color: var(--accent-standaard);
	}
	.teller {
		padding: 0 6px;
		border-radius: var(--vorm-pill);
		background: var(--accent-zacht);
		color: var(--accent-standaard);
		font: 600 12px/18px var(--tekst-familie);
	}
	.gradient {
		background: rgb(245 240 255 / 0.3);
		border-color: rgb(255 255 255 / 0.14);
	}
	.gradient .optie {
		color: var(--tekst-op-accent);
	}
	.gradient .actief {
		background: #fff;
		box-shadow: none;
		color: #6a55dc;
	}
</style>
