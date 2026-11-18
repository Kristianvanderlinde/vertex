<!-- Schakelaar (aan/uit). Gebruik binnen een <label> of geef een aria-label mee. -->
<script lang="ts">
	import type { HTMLInputAttributes } from 'svelte/elements';
	type Props = Omit<HTMLInputAttributes, 'type' | 'checked'> & { aan?: boolean };
	let { aan = $bindable(false), ...rest }: Props = $props();
</script>

<input class="schakelaar" type="checkbox" role="switch" bind:checked={aan} {...rest} />

<style>
	.schakelaar {
		all: unset;
		box-sizing: border-box;
		position: relative;
		flex-shrink: 0;
		width: 48px;
		height: 28px;
		border-radius: var(--vorm-pill);
		background: var(--achtergrond-vlak);
		cursor: pointer;
		transition: background-color 0.2s;
	}
	.schakelaar::after {
		content: '';
		position: absolute;
		top: 2px;
		left: 2px;
		width: 24px;
		height: 24px;
		border-radius: 50%;
		background: #fff;
		box-shadow: 0 2px 4px rgb(0 0 0 / 0.2);
		transition: transform 0.2s var(--ease, ease);
	}
	.schakelaar:checked {
		background: var(--accent-vlak);
	}
	.schakelaar:checked::after {
		transform: translateX(20px);
	}
	.schakelaar:focus-visible {
		outline: 2px solid var(--accent-standaard);
		outline-offset: 2px;
	}
	.schakelaar:disabled {
		opacity: 0.4;
		cursor: default;
	}
</style>
