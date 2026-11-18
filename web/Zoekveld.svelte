<!-- Zoekveld met zoekicoon. Het icoon geef je zelf mee, zodat het pakket geen icoonbibliotheek nodig heeft. -->
<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { HTMLInputAttributes } from 'svelte/elements';
	type Props = Omit<HTMLInputAttributes, 'type'> & { icoon?: Snippet; label?: string };
	let { value = $bindable(''), icoon, label = 'Zoeken', class: klas = '', ...rest }: Props = $props();
</script>

<label class="zoekveld {klas}">
	{#if icoon}<span class="icoon">{@render icoon()}</span>{/if}
	<span class="alleen-scherm-lezer">{label}</span>
	<input type="search" bind:value {...rest} />
</label>

<style>
	.zoekveld {
		display: flex;
		align-items: center;
		gap: var(--ruimte-2);
		min-height: 46px;
		padding: 0 var(--ruimte-4);
		background: var(--hoogte-1-vlak);
		border: 1px solid var(--lijn-standaard);
		border-radius: var(--vorm-md);
		color: var(--tekst-vaag);
		transition:
			border-color 0.15s,
			box-shadow 0.15s;
	}
	.zoekveld:focus-within {
		border-color: var(--accent-standaard);
		box-shadow: 0 0 0 4px var(--accent-zacht);
	}
	.icoon {
		display: inline-flex;
		color: var(--accent-standaard);
	}
	input {
		all: unset;
		flex: 1;
		min-width: 0;
		font: 400 15px/22px var(--tekst-familie);
		color: var(--tekst-hoofd);
	}
	input::placeholder {
		color: var(--tekst-vaag);
	}
	.alleen-scherm-lezer {
		position: absolute;
		width: 1px;
		height: 1px;
		overflow: hidden;
		clip: rect(0 0 0 0);
	}
</style>
