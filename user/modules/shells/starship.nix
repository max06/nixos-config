# starship prompt: tokyo-night preset with rounded separators and a
# kubernetes segment added. The preset ships a fixed `format`, so it is
# restated here. The kubernetes segment only appears once kubeswitch has set
# KUBECONFIG.
{ ... }:
let
  # Nerd Font powerline glyphs, built from code points so they survive
  # editors and tooling that drop private-use characters.
  glyph = codePoint: builtins.fromJSON ''"\u${codePoint}"'';
  roundRight = glyph "e0b4"; # right half circle: end of a segment
  roundLeft = glyph "e0b6"; # left half circle: start of the prompt
in
{
  programs.starship = {
    enable = true;
    presets = [ "tokyo-night" ];
    settings = {
      format = builtins.concatStringsSep "" [
        "[${roundLeft}](fg:#a3aed2)"
        "$os"
        "[${roundRight}](bg:#769ff0 fg:#a3aed2)"
        "$directory"
        "[${roundRight}](fg:#769ff0 bg:#394260)"
        "$git_branch"
        "$git_status"
        "[${roundRight}](fg:#394260 bg:#212736)"
        "$nodejs"
        "$bun"
        "$rust"
        "$golang"
        "$php"
        "$kubernetes"
        "[${roundRight}](fg:#212736 bg:#1d2230)"
        "$time"
        "[${roundRight}](fg:#1d2230)"
        "\n$character"
      ];

      kubernetes = {
        disabled = false;
        detect_env_vars = [ "KUBECONFIG" ];
        symbol = "☸";
        style = "bg:#212736";
        format = "[[ $symbol $context( \\($namespace\\)) ](fg:#769ff0 bg:#212736)]($style)";
      };
    };
  };
}
