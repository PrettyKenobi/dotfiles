# https://just.systems

cm_home := x'~/.local/share/chezmoi/home'
cm_template_dir := cm_home / ".chezmoitemplates"
# cm_windows_dir_local := cm_home / "AppData/Local"
# cm_windows_dir_roaming := cm_home / "AppData/Roaming"

default:
    echo 'Hello, world!'

# Create new base template in `./home/.chezmoitemplates`, then create template files in `./home/{{unix_location}}/{{target}}.{{ext}}.tmpl` and `./home/AppData/{{win_location}}.{{ext}}.tmpl`
[script("python3")]
new-template target unix_location win_location ext:
    from pathlib import Path

    target = Path('{{target}}')
    ext = Path('{{ext}}')
    f_name = str('{{target}}' + "." + '{{ext}}' + ".tmpl")
    f_name = Path(f_name)
    # Check that `{{target}}` doesn't exist
    template_path = Path('{{ cm_template_dir }}', target)
    unix_template_path = Path('{{ cm_home }}', '{{unix_location}}', f_name)
    windows_template_path = Path('{{cm_home}}', '{{win_location}}', f_name)

    if template_path.exists():
        print("File exists under .chezmoitemplates")
        c = input("Do you want to continue? [y/n] ")
        if c != "y":
            print("Stopping")
            exit()
    else:
        print("Making template")
        template = open(template_path, "x")
        template.close()
        if template.exists():
            print("Template created under .chezmoitemplates")

    if unix_template_path.exists():
        print("Unix template already exists.")
        c = input("Do you wish to continue? [y/n] ")
        if c != "y":
            print("Stopping")
            exit()
    else:
        print("Making unix template...")
        with open(unix_template_path, "x") as f:
            f.write("{{{{- template " + '{{target}}' + " -}}")
        if unix_template_path.exists():
            print("Unix template created!")

    if windows_template_path.exists():
        print("Windows template already exists.")
        c = input("Do you wish to continue? [y/n] ")
        if c != "y":
            print("Stopping...")
            exit()
    else:
        print("Making Windows template...")
        with open(windows_template_path, "x") as f:
            f.write("{{{{- template " + '{{target}}' + " -}}")
        if windows_template_path.exists():
            print("Windows template created")

    print("Dont forget to edit " + '{{target}}' + "!")
