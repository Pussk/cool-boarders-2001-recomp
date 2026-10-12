# Cool Boarders 2001 — recomp experimental para Windows

Protótipo de **Cool Boarders 2001, SCUS-94597 (NTSC-U)**, baseado no
[PSXRecomp](https://github.com/RetroPortingToolKit/psxrecomp), fixado no commit
`2a4824fcb897cb635438958f0c8cffb5a27df656`.

## Estado atual

- Executável local: `build/coolboard2001.exe`, com ícone do PlayStation.
- OpenGL com resolução interna de 1× a 4×, texturas bilineares e FXAA/FXAA HQ.
- Menu gráfico com perfis Desempenho, Equilibrado e Qualidade.
- GameSir G7/XInput e teclado; tecla **P** mostra/esconde FPS e velocidade.
- BIOS Sony SCPH-1001 v2.2 opcional, com abertura original e áudio.
- 16:9 usa apresentação Cinema: largura preenchida e barras horizontais.
  A imagem é alargada para preservar o conteúdo; não é zoom proporcional.
- Disco, BIOS, saves, capturas e código gerado do jogo permanecem locais.

O usuário confirmou corrida em velocidade normal e melhora do chão com OpenGL.
4× custa mais desempenho. Todas as pistas, áudio e salvamento ainda não têm
validação completa. O contador mede quadros de emulação: **1.00x** representa
velocidade normal, não necessariamente 60 imagens distintas por segundo.

## Abrir e configurar

Com os arquivos locais preparados e o executável compilado:

1. Abra **Jogar.cmd** ou **Graficos.cmd**.
2. Escolha resolução, anti-aliasing, texturas e proporção.
3. Clique em **Salvar e jogar**. As mudanças valem na próxima inicialização.

Equilibrado: OpenGL 2× + FXAA HQ + bilinear. Qualidade: OpenGL 4×.
Desempenho: software 1×. `Jogar-software.cmd` abre o perfil anterior por CPU.
O menu salva `game.toml` e atualiza `build/game.toml`; `game.toml.bak` guarda
as opções anteriores. 16:9/Cinema é experimental, incluindo o HUD e a geometria.

O dump usado no desenvolvimento contém uma abertura PARADOX. **B/Circle**
seleciona NTSC nessa abertura; Menu/Start avança e A/Cross confirma.
Teclado: S/Circle, Enter/Start e X/Cross. O GUID de controle no `game.toml`
corresponde ao GameSir G7 do desenvolvimento; outro controle pode exigir ajuste.

## Preparar uma instalação

Este repositório contém ferramentas e configuração; clonar sozinho não produz
um jogo pronto. Use seu próprio dump compatível e dependências do framework.

```powershell
git clone --recurse-submodules https://github.com/Pussk/cool-boarders-2001-recomp.git
cd cool-boarders-2001-recomp
```

São necessários Python, Git, CMake/Ninja, compilador C/C++ compatível com o
framework e suas dependências SDL3. Os scripts usam `--no-toolchain-download`:
a toolchain precisa estar instalada/configurada previamente.

Prepare localmente `disc/coolboarders2001.bin` e seu CUE. Se estiver em ECM,
restaure antes para BIN usando UNECM. O desenvolvimento usou uma única faixa
MODE2/2352, com BIN de 234.677.856 bytes e checksum ECM válido; a disposição
completa do disco original não foi confirmada. Extraia o boot PS-X EXE como
`disc/SCUS_945.97` usando o leitor de disco do framework. Em seguida:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1 -Generate
```

O build aplica automaticamente os patches locais em `patches/`, normaliza o
EXE, gera C e compila. Os patches mantêm o filtro nos resets da GPU, habilitam
OSD/FPS sem launcher e adicionam os modos de apresentação deste protótipo.
O submódulo continua fixado no upstream; as modificações são publicadas como
patches, sem publicar o código derivado de BIOS/jogo.

Sem BIOS Sony local, `play.ps1` usa OpenBIOS. Para a abertura Sony, coloque um
dump SCPH-1001 v2.2 em `psxrecomp/bios/SCPH1001.BIN` (SHA-256
`71af94d1e47a68c11e8fdb9f8368040601514a42a5a399cda48c7d3bff1e99d3`),
gere seu backend na pasta do framework e compile novamente:

```powershell
cd psxrecomp
./recompiler/build/psxrecomp-bios.exe --config bios/SCPH1001.toml
cd ..
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
```

O local do emissor pode variar conforme a toolchain. Os perfis do framework
validam o BIOS; não basta renomear outro arquivo. SCPH-5500 japonês foi testado,
mas não completou a abertura neste protótipo; SCPH-1001 é a opção validada.

## Limites e licenças

Não é uma recompilação inteiramente estática: são 45 funções geradas na análise
inicial, com suporte do runtime para código dinâmico. O launcher usa overlays
no caminho de referência, interpretados, para evitar falhas de compatibilidade
observadas; `play.ps1 -Native` permite comparar o modo nativo experimental.
A captura/substituição de texturas HD foi retirada; o projeto usa os filtros.

Consulte `THIRD_PARTY_NOTICES.md` e `assets/README.md`. O framework usa PolyForm
Noncommercial 1.0.0; UNECM usa GPL-2.0-or-later. O símbolo PlayStation é da Sony.
Nenhum jogo, BIOS proprietário ou executável pronto é distribuído aqui.
