"""script to run closest unit tests"""
import os
from subprocess import call, check_output


def find_up(query_dir, string):
    while query_dir is not "/":
        if string in os.listdir(query_dir):
            return query_dir
        else:
            query_dir = os.path.dirname(query_dir)


def unzoom():
    flags = check_output("tmux display-message -p '#F'".split(' '))
    if "Z" in str(flags):
        call("tmux resize-pane -Z", shell=True)


def assemble_command():
    module_dir = find_up(os.getcwd(), "__init__.py")
    try:
        module_name = os.path.basename(module_dir)
        base_dir = find_up(module_dir, "manage.py")
        return "python {}/manage.py test {}".format(base_dir, module_name)
    except AttributeError:
        return None


def main():
    command = assemble_command()
    if command:
        unzoom()
    call(command, shell=True)

if __name__ == "__main__":
    main()
