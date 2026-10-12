# Cool Boarders 2001 Recomp — protótipo Windows

Jogo identificado no disco: **SCUS-94597 (NTSC-U)**. Base: PSXRecomp,
commit `2a4824fcb897cb635438958f0c8cffb5a27df656`.

## Estado

- ECM restaurado para BIN: **234.677.856 bytes**, checksum ECM válido.
- Executável original extraído: `disc/SCUS_945.97`, **500.000 bytes**.
- Imagem de carga normalizada: **425.984 bytes**; o original foi preservado.
- Entrada: `0x800EEF70`; carga: `0x800B5800`; texto: `0x67800` bytes.
- Geração por descoberta alcançável: **45 funções**, **15.529 linhas de C**.
- Executável nativo compilado: `build/Cool_Boarders_2001_Recompiled.exe`.
- Boot, controle e menu principal confirmados por captura de imagem.
- No teste do menu, 127 entradas de módulos dinâmicos estavam registradas,
  com mais de 1,5 milhão de chamadas nativas; há fallback para interpretação.
- Áudio, carreira, salvamento e compatibilidade de todas as pistas não validados.

**Limite conhecido:** o teste automatizado com módulos nativos chegou ao menu,
mas não confirmou a entrada em Quick Race. Com a execução nativa dos overlays
desativada, os comandos alcançaram a seleção de snowboarder e a tela de
carregamento da pista (Hints). A corrida em andamento ainda não foi validada. Isso é uma
diferença observada que exige investigação; não comprova ainda qual função está
incorreta. Para comparar localmente: `./play.ps1 -Reference`.

Este é um protótipo. O framework pode interpretar e recompilar código
carregado dinamicamente; o jogo inteiro ainda não foi recompilado estaticamente.
A lista inicial de 87 destinos JAL foi mantida em `seeds/ghidra_funcs.txt` como
referência. A geração usa somente a entrada comprovada em `seeds/boot_entry.txt`
e segue o fluxo alcançável, evitando varrer dados como instruções.

## Executar

No PowerShell, dentro deste projeto:

```powershell
./play.ps1
```

Também é possível abrir `Jogar.cmd` com dois cliques. O atalho usa software
e o caminho de referência dos overlays para contornar a tela preta observada
na execução nativa. Para testar os overlays nativos: `./play.ps1 -Native`.
Essa configuração de compatibilidade ainda usa o boot e o BIOS recompilados,
mas interpreta os overlays; não é uma recompilação inteiramente estática.
O arquivo
`build/game.toml` recebe caminhos locais absolutos para permitir iniciar
o executável diretamente; `tools/stage_runtime_config.py` refaz esse arquivo.

O script usa caminhos absolutos para a configuração, disco e OpenBIOS.
O dump fornecido inclui uma abertura modificada PARADOX, anterior ao jogo.
Nessa tela, o botão **Circle** escolhe NTSC; depois **Start** avança a abertura
e **Cross** confirma no menu. Em controles Xbox, Circle corresponde a B e Cross a A.
Os arquivos do jogo permanecem locais em `disc/`, ignorados pelo Git.
O CUE foi reconstruído como uma faixa MODE2/2352 para analisar o BIN fornecido;
a disposição completa das faixas do disco original não foi verificada.

## Reproduzir a compilação

O repositório não inclui disco, BIOS, código gerado do jogo, executáveis ou
capturas. O código C deve ser regenerado localmente a partir do seu próprio
disco. Os hashes em `game.toml` identificam exatamente a imagem usada no teste;
outras revisões, inclusive dumps sem a abertura modificada, não foram validadas.

Clone com `git clone --recurse-submodules <URL-do-repositório>`. Prepare
seus arquivos locais como `disc/coolboarders2001.bin` e
`disc/coolboarders2001.cue`. Depois extraia o boot EXE sem sobrescrever
a configuração de descoberta alcançável:

```powershell
python psxrecomp/tools/new_project_layout/probe_disc.py disc/coolboarders2001.cue --write-boot-exe disc
```

Requer Python 3 e a ferramenta cmake-clang-v1 preparada pelo PSXRecomp:

```powershell
python psxrecomp/psxrecomp_cli.py ensure-toolchain --project-root .
./build.ps1 -Generate
```

Para apontar outro Python: `./build.ps1 -Generate -Python C:/caminho/python.exe`.
O framework fica em `psxrecomp/`; para recuperar uma cópia ausente:

```powershell
git clone https://github.com/RetroPortingToolKit/psxrecomp.git psxrecomp
git -C psxrecomp checkout 2a4824fcb897cb635438958f0c8cffb5a27df656
```

Não é necessário um BIOS comercial neste protótipo; o OpenBIOS acompanha o
framework. Rewind, netplay e launcher estão desativados.

## Diagnóstico

`disc_probe.json`, `disc_inventory.json` e `catalog_identity.json` registram
identidade, hashes e arquivos ISO9660. `generate.log` e `build.log` guardam
a geração e a compilação. `tools/smoke_boot.py` faz um boot limitado a 30 s.
`tools/diagnose_boot.py` consulta o runtime com `PSX_DEBUG_TOOLS=ON` e salva
estado e imagem, quando disponíveis, em `analysis/`.

Para recompilar com diagnóstico, ative a toolchain no PATH e rode:

```powershell
cmake -S . -B build -DPSX_DEBUG_TOOLS=ON -DPSX_REWIND=OFF
cmake --build build --parallel 2 --target psx-runtime
python tools/diagnose_boot.py --advance --samples 10
```

Evidência visual do menu: `analysis/menu.png`; estado: `analysis/menu_state.json`.
O piso de overlays foi ajustado para `0x10000` porque o diagnóstico mostrou
código em execução em `0x800215F8`, abaixo da imagem estática do boot EXE.

Os módulos `FRONTEND.BIN` e `MOVIE.BIN` são candidatos à investigação dos
carregamentos dinâmicos; suas funções ainda não foram identificadas.

## Origem das ferramentas

PSXRecomp: https://github.com/RetroPortingToolKit/psxrecomp

`tools/unecm.c`: UNECM de Neill Corlett, obtido de
https://github.com/37712/ECM-Tools, GPL-2.0-or-later conforme cabeçalho do arquivo.
O decodificador foi compilado localmente com Clang.
