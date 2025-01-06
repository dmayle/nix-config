{ pkgs, ... }:

{
  # Don't know what font to use for coding? Play a coding font tournament (best
  # with font names hidden) to figure out what you like:
  # https://www.codingfont.com/
  # I can't stand ligatures because single-equal and double-equal are too hard
  # to distinguish.
  # Most important for me is to choose the monospace font for terminals and
  # coding (for this, I care about a specific font).  After that, I just want
  # a nice looking default font, and to include the main common fonts like
  # Times New Roman, Courier, Helvetica, etc.
  # I like JetBrains Mono, Iosevka (ss13-lucida and ss16-ptmono)
  # (In Iosevka variants, I like an adjusted percent, zeros with slashes,
  # dollar signs with lines through them, asterisks at top height)
  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/conf.d/20-my-fontconfig.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      <alias>
        <family>monospace</family>
        <prefer>
          <family>JetBrains Mono NL</family>
          <!-- Setting a proper fallback is necessary for airline/powerline glyphs -->
          <family>Droid Sans Fallback</family>
          <family>Fira Code</family>
        </prefer>
      </alias>
      <match target="font">
        <edit name="rbga" mode="assign"><const>bgr</const></edit>
      </match>
      <match target="pattern">
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="assign" binding="same"><string>JetBrains Mono NL</string></edit>
        <!-- Setting a proper fallback is necessary for airline/powerline glyphs -->
        <edit name="family" mode="append" binding="same"><string>Droid Sans Fallback</string></edit>
        <edit name="family" mode="append" binding="same"><string>Fira Code</string></edit>
      </match>

      <!-- Noto ChromeOS fonts are very nice -->
      <alias>
        <family>serif</family>
        <prefer>
          <family>Noto Serif</family>
        </prefer>
      </alias>
      <match target="pattern">
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Serif</string></edit>
      </match>

      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans</family>
        </prefer>
      </alias>
      <match target="pattern">
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Sans</string></edit>
      </match>

      <!-- Specific fix for PDFs typeset with TeX and LaTeX -->
      <match target="pattern">
        <test qual="any" name="family"><string>NewCenturySchlbk</string></test>
        <edit name="family" mode="assign" binding="same"><string>TeX Gyre Schola</string></edit>
      </match>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    # Fonts
    corefonts
    fira-code-symbols
    freefont_ttf
    gyre-fonts
    helvetica-neue-lt-std
    material-design-icons
    material-icons
    material-symbols
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];
}
