<!-- Ronde knop met alleen een icoon. Standaard (kaartvlak met rand en schaduw), getint of primair. Altijd een aria-label meegeven. -->
<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { HTMLButtonAttributes } from 'svelte/elements';

	type Props = Omit<HTMLButtonAttributes, 'children'> & {
		stijl?: 'standaard' | 'getint' | 'primair';
		maat?: 40 | 32;
		href?: string;
		'aria-label': string;
		children: Snippet;
	};
	let { stijl = 'standaard', maat = 40, href, children, class: klas = '', ...rest }: Props = $props();
</script>

{#if href}
	<a class="ik {stijl} {klas}" style:--maat="{maat}px" {href} aria-label={rest['aria-label']}>{@render children()}</a>
{:else}
	<button class="ik {stijl} {klas}" style:--maat="{maat}px" type="button" {...rest}>{@render children()}</button>
{/if}

<style>
	.ik {
		all: unset;
		box-sizing: border-box;
		display: inline-grid;
		place-items: center;
		flex-shrink: 0;
		width: var(--maat);
		height: var(--maat);
		border-radius: 50%;
		cursor: pointer;
		transition:
			filter 0.15s,
			transform 0.15s;
	}
	.standaard {
		background: var(--hoogte-2-vlak);
		border: 1px solid var(--hoogte-2-rand);
		box-shadow: var(--schaduw-hoogte-2);
		color: var(--accent-standaard);
	}
	.getint {
		background: var(--accent-zacht);
		color: var(--accent-standaard);
	}
	.primair {
		background: var(--verloop-accent);
		color: var(--tekst-op-accent);
		box-shadow: var(--schaduw-accent);
	}
	.ik:hover {
		filter: brightness(0.97);
	}
	.primair:hover {
		filter: brightness(1.08);
	}
	.ik:active {
		transform: scale(0.94);
	}
	.ik:focus-visible {
		outline: 2px solid var(--accent-standaard);
		outline-offset: 2px;
	}
	.ik:disabled {
		opacity: 0.4;
		cursor: default;
		transform: none;
	}
</style>
