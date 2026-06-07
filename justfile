# https://just.systems

cm_home := "~/.local/share/chezmoi/home"
cm_template_dir := cm_home / ".chezmoitemplates"
cm_windows_dir_local := cm_home / "AppData/Local"
cm_windows_dir_roaming := cm_home / "AppData/Roaming"

default:
    echo 'Hello, world!'

# Create new base template in `./home/.chezmoitemplates`, then create template files in `./home/{{unix_location}}/{{target}}.{{ext}}.tmpl` and `./home/AppData/{{win_location}}.{{ext}}.tmpl`
new-template target unix_location win_location ext:
    #!/usr/bin/env python3
    from pathlib import Path

    # Check that {{target}} doesn't exist
    template_path = Path({{cm_template_dir}}, {{target}})
    unix_template_path = Path({{unix_location}}, {{target}} + "." + {{ext}} + "tmpl")
    windows_template_path = Path({{win_location}}, {{target}} + "." + {{ext}} + "tmpl")

    if template_path.exists():
        print("File exists under .chezmoitemplates")
        c = input("Do you want to continue? [y/n] ")
        if c == "y":
            continue
        else:
            print("Stopping")
            break
    else:
        print("Making template")
        template = open(template_path, "x")
        template.close()
        if template.exists():
            print("Template created under .chezmoitemplates")

    if unix_template_path.exists():
        print("Unix template already exists.")
        c = input("Do you wish to continue? [y/n] ")
        if c == "y":
            continue
        else:
            print("Stopping")
            break
    else:
        print("Making unix template...")
        unix_template = open(unix_template_path, "x")
        unix_template.close()
        with open(unix_template) as f:
            f.write("{{{{- template " + {{target}} + " -}}")
        if unix_template.exists():
            print("Unix template created!")

    if windows_template_path.exists():
        print("Windows template already exists.")
        c = input("Do you wish to continue? [y/n] ")
        if c == "y":
            continue
        else:
            print("Stopping...")
            break
    else:
        print("Making Windows template...")
        windows_template = open(unix_template_path, "x")
        unix_template.close()
        with open(windows_template) as f:
            f.write("{{{{- template " + {{target}} + " -}}")
        if windows_template.exists():
            print("Windows template created")

    print("Dont forget to edit " + {{target}} + "!")
