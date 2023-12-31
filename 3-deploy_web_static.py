#!/usr/bin/python3
""" Deploy files to remote server using Fabric """
from datetime import datetime
from fabric.api import *
import os
import shlex


env.hosts = ['18.234.193.22', '34.227.90.136']
env.user = "ubuntu"


def deploy():
    """ Deploys """
    try:
        archive_path = do_pack()
        if not archive_path:
            return False
    except Exception as e:
        print(e)
        return False

    return do_deploy(archive_path)


def do_pack():
    try:
        if not os.path.exists("versions"):
            local('mkdir versions')
        t = datetime.now()
        f = "%Y%m%d%H%M%S"
        archive_path = 'versions/web_static_{}.tgz'.format(t.strftime(f))
        local('tar -cvzf {} web_static'.format(archive_path))
        return archive_path
    except Exception as e:
        print(e)
        return None


def do_deploy(archive_path):
    """ Upload archive to web servers """
    if not os.path.exists(archive_path):
        return False
    try:
        name = os.path.basename(archive_path)
        vname = name.split('.')[0]

        releases_path = "/data/web_static/releases/{}/".format(vname)
        tmp_path = "/tmp/{}".format(name)

        put(archive_path, tmp_path)
        run("mkdir -p {}".format(releases_path))
        run("tar -xzf {} -C {}".format(tmp_path, releases_path))
        run("rm {}".format(tmp_path))
        run("mv {}web_static/* {}".format(releases_path, releases_path))
        run("rm -rf {}web_static".format(releases_path))
        run("rm -rf /data/web_static/current")
        run("ln -s {} /data/web_static/current".format(releases_path))
        print("New version deployed!")
        return True
    except Exception as e:
        print(e)
        return False
