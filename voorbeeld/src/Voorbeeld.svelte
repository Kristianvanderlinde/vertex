<script lang="ts">
	import tokens from '../../tokens/tokens.json';
	import { Knop, Icoonknop, Chip, Segmentbalk, Schakelaar, Zoekveld } from '../../web';

	const groepen = ['achtergrond', 'hoogte', 'tekst', 'lijn', 'accent', 'status', 'categorie'];
	const semantisch = Object.keys(tokens.semantisch);
	const stijlen = Object.entries(tokens.tekst.stijlen);
	const varName = (n: string) => '--' + n.replace(/\//g, '-');

	let status = $state('open');
	let weergave = $state('lijst');
	let zoek = $state('');
	let aan = $state(true);
	let uit = $state(false);
</script>

{#snippet plus()}
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14" /></svg>
{/snippet}
{#snippet zoekIcoon()}
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM20 20l-4-4" /></svg>
{/snippet}

{#snippet paneel(thema: 'licht' | 'donker')}
	<div class="paneel" data-thema={thema}>
		<div class="gloed"></div>
		<h1 class="tekst-titel-m">Vertex · {thema}</h1>

		<h2 class="tekst-kop">Componenten</h2>
		<div class="blok">
			<h3 class="tekst-body-vet gedempt">Knop</h3>
			<div class="rij">
				<Knop variant="primair" icoon={plus}>Primair</Knop>
				<Knop variant="secundair">Secundair</Knop>
				<Knop variant="tertiair">Tertiair</Knop>
				<Knop variant="destructief">Verwijderen</Knop>
				<Knop variant="primair" disabled>Uitgeschakeld</Knop>
			</div>
			<div class="rij">
				<Knop variant="primair" maat="l">Groot</Knop>
				<Knop variant="secundair" maat="l">Groot</Knop>
				<Knop variant="primair" maat="s">Klein</Knop>
				<Knop variant="secundair" maat="s">Klein</Knop>
			</div>
			<h3 class="tekst-body-vet gedempt">Icoonknop</h3>
			<div class="rij">
				<Icoonknop aria-label="Nieuw">{@render plus()}</Icoonknop>
				<Icoonknop stijl="getint" aria-label="Nieuw">{@render plus()}</Icoonknop>
				<Icoonknop stijl="primair" aria-label="Nieuw">{@render plus()}</Icoonknop>
				<Icoonknop maat={32} aria-label="Nieuw">{@render plus()}</Icoonknop>
			</div>
			<h3 class="tekst-body-vet gedempt">Chip</h3>
			<div class="rij">
				<Chip toon="accent">2 delen</Chip>
				<Chip toon="positief">Binnen</Chip>
				<Chip toon="waarschuwing">Indelen</Chip>
				<Chip toon="neutraal">Overboeking</Chip>
				<Chip toon="negatief">Te veel</Chip>
				<Chip toon="accent" onclick={() => {}}>Albert Heijn ✕</Chip>
			</div>
			<h3 class="tekst-body-vet gedempt">Segmentbalk</h3>
			<div class="rij">
				<Segmentbalk bind:waarde={status} opties={[{ waarde: 'alles', label: 'Alles' }, { waarde: 'open', label: 'Nog indelen', teller: 6 }, { waarde: 'terug', label: 'Terug verwacht', teller: 1 }]} />
				<Segmentbalk bind:waarde={weergave} opties={[{ waarde: 'lijst', label: 'Lijst' }, { waarde: 'tabel', label: 'Tabel' }]} />
			</div>
			<div class="kaartje">
				<Segmentbalk achtergrond="gradient" waarde="a" opties={[{ waarde: 'a', label: 'Maand' }, { waarde: 'b', label: 'Jaar' }]} />
			</div>
			<h3 class="tekst-body-vet gedempt">Schakelaar en zoekveld</h3>
			<div class="rij">
				<Schakelaar bind:aan aria-label="Aan" />
				<Schakelaar bind:aan={uit} aria-label="Uit" />
				<Zoekveld bind:value={zoek} placeholder="Zoek op naam, omschrijving of bedrag" icoon={zoekIcoon} />
			</div>
		</div>

		<h2 class="tekst-kop">Kleur</h2>
		{#each groepen as g}
			<h3 class="tekst-body-vet gedempt">{g}</h3>
			<div class="kleuren">
				{#each semantisch.filter((n) => n.startsWith(g + '/')) as n}
					<div class="kleur">
						<span class="vlak" style:background="var({varName(n)})"></span>
						<span class="tekst-klein">{n.split('/')[1]}</span>
					</div>
				{/each}
			</div>
		{/each}

		<h2 class="tekst-kop">Primitieven</h2>
		{#each Object.entries(tokens.primitieven) as [fam, schaal]}
			<div class="schaal">
				<span class="tekst-klein gedempt fam">{fam}</span>
				{#each Object.keys(schaal) as stap}
					<span class="stap" style:background="var(--{fam}-{stap})" title="{fam}/{stap}"></span>
				{/each}
			</div>
		{/each}

		<h2 class="tekst-kop">Tekst</h2>
		{#each stijlen as [naam, s]}
			<div class="tekstrij">
				<span class="tekst-{naam}">Boodschappen in oktober</span>
				<span class="tekst-klein gedempt">{naam} · {s.grootte}/{s.regelhoogte} · {s.gewicht}</span>
			</div>
		{/each}

		<h2 class="tekst-kop">Verloop</h2>
		<div class="rij"><div class="verloop" style:background="var(--verloop-accent)"><span class="tekst-klein">accent</span></div></div>

		<h2 class="tekst-kop">Hoogte</h2>
		<div class="rij hoogte">
			{#each [1, 2, 3, 4] as n}
				<div class="niveau" style="background: var(--hoogte-{n}-vlak); border: 1px solid var(--hoogte-{n}-rand); box-shadow: var(--schaduw-hoogte-{n});">
					<span class="tekst-body-vet">Hoogte {n}</span>
					<span class="tekst-klein gedempt">{['kaart', 'verhoogd', 'zwevend', 'overlay'][n - 1]}</span>
				</div>
			{/each}
		</div>

		<h2 class="tekst-kop">Vorm en ruimte</h2>
		<div class="rij">
			{#each Object.keys(tokens.vorm) as k}
				<div class="vorm" style:border-radius="var(--vorm-{k})"><span class="tekst-klein">{k}</span></div>
			{/each}
		</div>
		<div class="ruimtes">
			{#each Object.entries(tokens.ruimte) as [k, v]}
				<div class="ruimte"><span class="balk" style:width="var(--ruimte-{k})"></span><span class="tekst-klein gedempt">{k} · {v}</span></div>
			{/each}
		</div>
	</div>
{/snippet}

<div class="pagina">
	{@render paneel('licht')}
	{@render paneel('donker')}
</div>

<style>
	.pagina {
		display: grid;
		grid-template-columns: 1fr 1fr;
		min-height: 100vh;
		font-family: var(--tekst-familie);
	}
	.paneel {
		position: relative;
		overflow: hidden;
		padding: var(--ruimte-8);
		background: var(--achtergrond-pagina);
		color: var(--tekst-hoofd);
		display: flex;
		flex-direction: column;
		gap: var(--ruimte-3);
	}
	.gloed {
		position: absolute;
		inset: 0 0 auto 0;
		height: 300px;
		background: var(--verloop-gloed);
		pointer-events: none;
	}
	.paneel > :global(*:not(.gloed)) {
		position: relative;
	}
	h1,
	h2,
	h3 {
		margin: var(--ruimte-4) 0 0;
	}
	.gedempt {
		color: var(--tekst-gedempt);
	}
	.blok {
		display: flex;
		flex-direction: column;
		gap: var(--ruimte-3);
	}
	.kaartje {
		background: var(--verloop-accent);
		padding: var(--ruimte-5);
		border-radius: var(--vorm-xl);
		width: fit-content;
	}
	.kleuren {
		display: flex;
		flex-wrap: wrap;
		gap: var(--ruimte-3);
	}
	.kleur {
		display: flex;
		flex-direction: column;
		gap: var(--ruimte-1);
		width: 96px;
	}
	.vlak {
		height: 48px;
		border-radius: var(--vorm-md);
		border: 1px solid var(--lijn-standaard);
	}
	.schaal {
		display: flex;
		align-items: center;
		gap: var(--ruimte-1);
	}
	.fam {
		width: 72px;
	}
	.stap {
		width: 36px;
		height: 28px;
		border-radius: var(--vorm-sm);
		border: 1px solid var(--lijn-standaard);
	}
	.tekstrij {
		display: flex;
		justify-content: space-between;
		align-items: baseline;
		gap: var(--ruimte-4);
	}
	.rij {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: var(--ruimte-4);
	}
	.hoogte {
		padding: var(--ruimte-4) 0 var(--ruimte-6);
	}
	.niveau {
		width: 140px;
		height: 96px;
		border-radius: var(--vorm-xl);
		padding: var(--ruimte-4);
		display: flex;
		flex-direction: column;
		justify-content: flex-end;
	}
	.verloop,
	.vorm {
		width: 120px;
		height: 80px;
		display: grid;
		place-items: center;
	}
	.verloop {
		border-radius: var(--vorm-xl);
		color: var(--tekst-op-accent);
	}
	.vorm {
		background: var(--accent-zacht);
		color: var(--accent-standaard);
	}
	.ruimtes {
		display: flex;
		flex-direction: column;
		gap: var(--ruimte-1);
	}
	.ruimte {
		display: flex;
		align-items: center;
		gap: var(--ruimte-3);
	}
	.balk {
		height: 12px;
		background: var(--accent-vlak);
		border-radius: var(--vorm-pill);
	}
</style>
