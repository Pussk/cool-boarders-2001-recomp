param([switch]$Check, [switch]$CheckSave)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$taskConfigPath = Join-Path $PSScriptRoot 'game.toml'
$taskConfigText = [IO.File]::ReadAllText($taskConfigPath)
function Read-VideoValue([string]$key, [string]$fallback) {
    $section = [regex]::Match($taskConfigText, '(?ms)^\[video\]\s*\r?\n(.*?)(?=^\[|\z)').Groups[1].Value
    $m = [regex]::Match($section, '(?m)^' + [regex]::Escape($key) + '\s*=\s*([^\r\n#]+)')
    if ($m.Success) { return $m.Groups[1].Value.Trim().Trim('"') }
    return $fallback
}
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Cool Boarders 2001 — Gráficos'
$form.ClientSize = New-Object System.Drawing.Size(500,440)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI',10)
$iconPath = Join-Path $PSScriptRoot 'assets/ps1.ico'
if (Test-Path $iconPath) { $form.Icon = New-Object System.Drawing.Icon($iconPath) }
$title = New-Object System.Windows.Forms.Label
$title.Text = 'Escolha como jogar'
$title.Font = New-Object System.Drawing.Font('Segoe UI',16,[System.Drawing.FontStyle]::Bold)
$title.SetBounds(22,18,450,36)
$form.Controls.Add($title)
$script:choices = @{}
function Add-Choice([string]$key,[string]$label,[int]$y,[string[]]$values,[string]$selected) {
    $caption = New-Object System.Windows.Forms.Label
    $caption.Text = $label; $caption.SetBounds(24,$y,180,28)
    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.DropDownStyle = 'DropDownList'; $combo.SetBounds(208,$y,264,28)
    $combo.Items.AddRange([object[]]$values)
    $combo.SelectedItem = $selected
    if ($combo.SelectedIndex -lt 0) { $combo.SelectedIndex = 0 }
    $form.Controls.Add($caption); $form.Controls.Add($combo)
    $script:choices[$key] = $combo
}
Add-Choice 'profile' 'Perfil' 72 @('Personalizado','Desempenho','Equilibrado','Qualidade') 'Personalizado'
Add-Choice 'renderer' 'Renderizador' 112 @('opengl','software') (Read-VideoValue 'renderer' 'opengl')
Add-Choice 'scale' 'Resolução interna' 152 @('1','2','3','4') (Read-VideoValue 'supersampling' '2')
Add-Choice 'aa' 'Anti-aliasing' 192 @('off','fxaa','fxaa_hq') (Read-VideoValue 'antialiasing_mode' 'off')
Add-Choice 'texture' 'Texturas' 232 @('nearest','bilinear') (Read-VideoValue 'texture_filtering' 'nearest')
Add-Choice 'aspect' 'Proporção' 272 @('4:3','16:9') (Read-VideoValue 'aspect_ratio' '4:3')
$script:settingProfile = $false
$choices.profile.Add_SelectedIndexChanged({
    $script:settingProfile = $true
    switch ([string]$choices.profile.SelectedItem) {
        'Desempenho' { $choices.renderer.SelectedItem='software'; $choices.scale.SelectedItem='1'; $choices.aa.SelectedItem='off'; $choices.texture.SelectedItem='nearest'; $choices.aspect.SelectedItem='4:3' }
        'Equilibrado' { $choices.renderer.SelectedItem='opengl'; $choices.scale.SelectedItem='2'; $choices.aa.SelectedItem='fxaa_hq'; $choices.texture.SelectedItem='bilinear'; $choices.aspect.SelectedItem='4:3' }
        'Qualidade' { $choices.renderer.SelectedItem='opengl'; $choices.scale.SelectedItem='4'; $choices.aa.SelectedItem='fxaa_hq'; $choices.texture.SelectedItem='bilinear'; $choices.aspect.SelectedItem='4:3' }
    }
    $script:settingProfile = $false
})
foreach ($key in @('renderer','scale','aa','texture','aspect')) {
    $choices[$key].Add_SelectedIndexChanged({ if (!$script:settingProfile) { $choices.profile.SelectedItem='Personalizado' } })
}
$note = New-Object System.Windows.Forms.Label
$note.Text = '1× a 4× por eixo. Qualidade custa mais desempenho. 16:9 usa imagem larga com barras horizontais (Cinema). As opções entram em vigor ao iniciar o jogo.'
$note.SetBounds(24,313,450,54); $form.Controls.Add($note)
function Save-Graphics {
    $text = [IO.File]::ReadAllText($taskConfigPath)
    $match = [regex]::Match($text,'(?ms)^\[video\]\s*\r?\n.*?(?=^\[|\z)')
    if (!$match.Success) { throw 'Seção [video] não encontrada.' }
    $video = $match.Value
    $fields = [ordered]@{renderer=[string]$choices.renderer.SelectedItem; supersampling=[string]$choices.scale.SelectedItem; antialiasing_mode=[string]$choices.aa.SelectedItem; texture_filtering=[string]$choices.texture.SelectedItem; aspect_ratio=[string]$choices.aspect.SelectedItem}
    foreach ($key in $fields.Keys) {
        $value = $fields[$key]
        if ($key -ne 'supersampling') { $value = '"' + $value + '"' }
        $line = $key + ' = ' + $value
        $pattern = '(?m)^' + [regex]::Escape($key) + '\s*=[^\r\n]*'
        if ([regex]::IsMatch($video,$pattern)) { $video = [regex]::Replace($video,$pattern,$line) }
        else { $video = $video.TrimEnd() + "`r`n" + $line + "`r`n`r`n" }
    }
    $text = $text.Substring(0,$match.Index) + $video + $text.Substring($match.Index+$match.Length)
    Copy-Item -LiteralPath $taskConfigPath -Destination (Join-Path $PSScriptRoot 'game.toml.bak') -Force
    [IO.File]::WriteAllText($taskConfigPath,$text,(New-Object System.Text.UTF8Encoding($false)))
    # Keep direct executable launch in sync while preserving its absolute disc paths.
    $staged = Join-Path $PSScriptRoot 'build/game.toml'
    if (Test-Path $staged) {
        $stagedText = [IO.File]::ReadAllText($staged)
        $stagedText = [regex]::Replace($stagedText,'(?ms)^\[video\]\s*\r?\n.*?(?=^\[|\z)',[System.Text.RegularExpressions.MatchEvaluator]{param($m) $video})
        [IO.File]::WriteAllText($staged,$stagedText,(New-Object System.Text.UTF8Encoding($false)))
    }
}
$save = New-Object System.Windows.Forms.Button
$save.Text='Salvar'; $save.SetBounds(24,382,112,34)
$save.Add_Click({ try { Save-Graphics; $form.Close() } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Não foi possível salvar') } })
$play = New-Object System.Windows.Forms.Button
$play.Text='Salvar e jogar'; $play.SetBounds(148,382,190,34)
$script:launchGame = $false
$play.Add_Click({ try { Save-Graphics; $script:launchGame=$true; $form.Close() } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Não foi possível salvar') } })
$cancel = New-Object System.Windows.Forms.Button
$cancel.Text='Cancelar'; $cancel.SetBounds(350,382,122,34); $cancel.Add_Click({$form.Close()})
$form.Controls.AddRange(@($save,$play,$cancel)); $form.AcceptButton=$play; $form.CancelButton=$cancel
if ($CheckSave) { $choices.scale.SelectedItem='4'; $choices.aspect.SelectedItem='16:9'; Save-Graphics; Write-Output 'Salvo: 4x, 16:9'; $form.Dispose(); exit 0 }
if ($Check) { Write-Output ('Menu criado: ' + $choices.Count + ' opções'); $form.Dispose(); exit 0 }
[void]$form.ShowDialog(); $form.Dispose()
if ($script:launchGame) { & (Join-Path $PSScriptRoot 'play.ps1') }
