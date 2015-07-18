#!/bin/sh

install_apt_cyg()
{
    echo ""
}

log()
{
    echo ""
    echo ---------
    echo ""
    echo $*
    echo ""
    echo ---------
}

verify()
{
    which $1 > /dev/null && return
    [ -e /sbin/$1 ] && return
    [ -e /bin/$1 ] && return
    [ -e /usr/sbin/$1 ] && return
    [ -e /usr/bin/$1 ] && return

    shift
    echo ""
    for msg
    do
        echo $msg
    done
    echo ""
    exit 1
}

set_qmake()
{
    $qmake --version 2> /dev/null > /dev/null && return
    qmake=qmake-qt5
    $qmake --version 2> /dev/null > /dev/null && return
    qmake=qmake
    $qmake --version 2> /dev/null > /dev/null && return
    qmake=qmake-qt4
}

install_debian_tools()
{
    verify apt-get \
        "apt-get does not seem to be in your PATH.  It should be in" \
        "/usr/bin on Ubuntu and other Debian-based systems.  If you need" \
        "help with this, email me at ray.seyfarth@gmail.com."

    log Installing required tools and libraries

    sudo apt-get install make git gdb g++ astyle gfortran yasm \
         libqt5widgets5 libqt5core5a libqt5network5 libqt5opengl5-dev \
         libqt5quick5 libqt5qml5 libqt5sql5 libqt5webkit5-dev \
         qtbase5-dev qtbase5-dev-tools \
         bison flex
}

install_redhat_tools()
{
    verify yum \
        "yum does not seem to be in your PATH.  It should be in /usr/bin" \
        "on Fedora and othere Redhat-based systems.  If you need help with" \
        "this, echo email me at ray.seyfarth@gmail.com."

    log Installing required tools and libraries

    sudo yum install gcc-c++ make git gdb astyle gcc-gfortran yasm "qt5-*" \
        bison flex

    qmake=qmake-qt5
}

install_mageia_tools()
{
    verify urpmi \
        "urpmi does not seem to be in your PATH.  It should be in /sbin" \
	"on Mageia.  If you need help with this, email me at" \
        "ray.seyfarth@gmail.com"

    log Installing required tools and libraries

    sudo urpmi gcc-c++ gcc gcc-gfortran astyle yasm qtbase5-common-devel \
	make qttools5 libqt5webkitwidgets-devel bison flex
}

install_slackware_tools()
{
## slackware installs stuff as root
    if [ ! $UID = 0 ]
    then
        echo ""
        echo This script must be run as root.
        echo ""
        exit 1
    fi

    verify wget \
        "wget does not seem to be in your PATH.  It should be in /usr/bin" \
        "on Slackware systems. If you need help with this, email me at" \
        "ray.seyfarth@gmail.com."

    verify upgradepkg \
        "upgradepkg does not seem to be in your PATH.  It should be in" \
        "/usr/bin echo on Slackware systems. If you need help with this," \
        "email me at echo ray.seyfarth@gmail.com."

    log Installing required tools and libraries

    ## saves a little typing  ;-)
    MY_PKG=astyle
    MY_REPO=~/${MY_PKG}Build/slackbuilds.org/cgit/slackbuilds/plain/development/${MY_PKG}

    ## grab the goods!
    wget -r -np http://slackbuilds.org/cgit/slackbuilds/plain/development/${MY_PKG}/ -P ~/${MY_PKG}Build/

    old=`pwd`
    cd ${MY_REPO}/
    . $PWD/${MY_PKG}.info
    wget -N $DOWNLOAD -P ${MY_REPO}/
    ## finally run the build
    sh $PWD/${MY_PKG}.SlackBuild
    ls -t --color=never /tmp/${MY_PKG}-*_SBo.tgz | head -1 | xargs -i upgradepkg --install-new {}
    cd $old
}

install_bsd_tools()
{
    verify pkg \
        "pkg does not seem to be in your PATH.  It should be in /usr/bin" \
        "on BSD systems.  If you need help with this, email me at" \
        "ray.seyfarth@gmail.com."

    log Installing required tools and libraries

    sudo pkg install -y git gdb binutils astyle yasm qt4 qt4-opengl 
}

install_cygwin_tools()
{
    echo "---------"
    echo " "
    echo "Ebe is currently not supported under Cygwin."
    echo "You can find Windows installation exes at"
    echo "http://sourceforge.net/projects/qtebe/files/Windows."
    echo " "
    echo "---------"

    exit 1

    install_apt_cyg
    apt-cyg install git gdb gcc gcc-g++ gcc-fortran make binutils \
            astyle qt4-devel-tools libQtCore4-devel libQtDBus4 \
            libQtDeclarative4 libQtDesigner4 -libQtGui4-devel \
            libQtHelp4 libQtNetwork4-devel libQtOpenGL4 libQtScript4-devel \
            libQtScriptTools4-devel libQtSql4 libQtWebKit4-devel libQtXml4 \
            libQtXmlPatterns4  bison flex
}

install_osx_tools()
{
    verify xcode-select \
        "xcode-select does not seem to be in your PATH.  This probably" \
        "means that the XCode compilation system is not installed.  This" \
        "needs to be done from the App Store (Apple menu at the upper left)"

    log Installing XCode command line tools

    xcode-select --install

    tool=brew
    brew_installed=false
    if which brew > /dev/null
    then
        brew_installed=true
    elif which port > /dev/null
    then
        tool=port
    fi
    
    if [ tool = port ]
    then
        log Installing required tools and libraries with port command
        sudo port install git gdb g95 astyle yasm qt5-mac bison flex
    else
        if [ brew_installed = false ]
        then
            log Installing homebrew and running brew doctor
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            brew doctor
        fi

        verify brew \
            "Neither MacPorts nor Homebrew seems to be installed." \
            "An attempt was made to install Homebrew from http://brew.sh" \
            "Sorry, try to install one of these and retry the script."

        log Installing required tools and libraries with brew command
        brew install git gcc homebrew/dupes/gdb qt5 astyle yasm bison flex
        brew link --overwrite gdb
        brew link --force qt5
        ln -s /usr/local/bin/gcc-4.9 /usr/local/bin/gcc
        ln -s /usr/local/bin/g++-4.9 /usr/local/bin/g++

    fi

    if [ tool = port ]
    then
        log Signing the certificate for ggdb
        sudo codesign -s gdb-cert /opt/local/bin/ggdb
    else
        log Signing the certificate for gdb
        sudo codesign -s gdb-cert /usr/local/bin/gdb
    fi

    log Restarting taskgated

    sudo killall -9 taskgated
}

install_aix_tools()
{
    echo " "
    echo "Sorry, AIX is not supported."
    echo "I do not have an AIX computer."
    echo "Perhaps I could help with a little help from you."
    echo "If you can help, email ray.seyfarth@gmail.com"
    exit 1
}

install_mandrake_tools()
{
    echo " "
    echo "Sorry, Mandrake is not currently supported."
    echo "For help, email ray.seyfarth@gmail.com"
    exit 1
}

install_solaris_tools()
{
    echo " "
    echo "Sorry, Solaris is not currentily supported."
    echo "For help, email ray.seyfarth@gmail.com"
    exit 1
}

install_suse_tools()
{
    verify zypper \
        "This appears to be a suse system without the zypper program" \
        "which is the suse command line package tool.  This will not work"

    log Installing required tools and libraries

    sudo zypper install gcc gcc-fortran gdb yasm astyle git \
        libqt5-qttools libqt5-qttools-devel libQt5WebkitWidgets-devel \
        bison flex

    qmake=qmake-qt5
}

install_arch_tools()
{
    log Installing required tools and libraries

    sudo pacman -S --noconfirm gcc gcc-fortran git astyle yasm qt5 \
        extra/gdb bison flex
        
}

install_gentoo_tools()
{
    echo " "
    echo "Sorry, Gentoo is not currentily supported."
    echo "For help, email ray.seyfarth@gmail.com"
    exit 1
}

get_and_build_ebe()
{
    log "Cloning ebe source code from sourceforge"

    if [ -x ebe ]
    then
        echo " "
        echo " "
        echo 'There appears to be an existing ebe directory (or file)'
        echo " "
        printf "Remove ebe and clone (Y/n)? "
        read ans
        if [ x$ans = 'xn' ]
        then
            exit 1
        fi
        rm -rf ebe
    fi

    verify git \
        "git does not seem to be in your PATH.  For help, contact me at" \
        "ray.seyfarth@gmail.com"

    git clone $version git://git.code.sf.net/p/qtebe/code ebe

    log "Compiling ebe.  This could take a few minutes"

    cd ebe
    ./qrc

    verify $qmake \
        "$qmake does not seem to be in your PATH.  For help, contact me at" \
        "ray.seyfarth@gmail.com"

    set_qmake
    $qmake

    verify make \
        "make does not seem to be in your PATH.  For help, contact me at" \
        "ray.seyfarth@gmail.com"

    make -j 4 2>&1 > ebe.log

    log "Compiling ebedecl"

    verify make \
        "make does not seem to be in your PATH.  For help, contact me at" \
        "ray.seyfarth@gmail.com"

    verify make \
        "make does not seem to be in your PATH.  For help, contact me at" \
        "ray.seyfarth@gmail.com"

    cd ebedecl
    make
    cd ..

    log 'Copying ebe and its language files (*.qm) to /usr/bin'

    $sudo cp ebe *.qm ebedecl/ebedecl /usr/bin
    $sudo chmod a+rx /usr/bin/ebe*
}

#  Main part of the script

version=$1
if [ x$version != x ]
then
    version="-b $version"
fi

sudo=sudo
qmake=qmake
os=unknown

name=$(uname -s)
echo $name

if [ $name = Darwin ]
then
    os=osx
elif [ $name = SunOS ]
then
    os=solaris
elif [ $name = aix ]
then
    os=aix
elif echo $name | grep -qi cygwin 2> /dev/null
then
    os=cygwin
    sudo=""
    qmake=qmake-qt4
elif echo $name | grep -qi bsd 2> /dev/null
then
    os=bsd
elif [ $name = Linux ]
then
    if [ -f /etc/mageia-release ]
    then
        os=mageia
    elif [ -f /etc/redhat-release ]
    then
        os=redhat
    elif [ -f /etc/debian_version ]
    then
        os=debian
    elif [ -f /etc/SuSE-release ]
    then
        os=suse
    elif [ -f /etc/mandrake-release ]
    then
        os=mandrake
    elif [ -f /usr/bin/pacman ]
    then
        os=arch
    fi
fi

echo $os

if [ $os = debian ]
then
    install_debian_tools
elif [ $os = redhat ]
then
    install_redhat_tools
elif [ $os = mageia ]
then
    install_mageia_tools
elif [ $os = bsd ]
then
    install_bsd_tools
elif [ $os = cygwin ]
then
    install_cygwin_tools
elif [ $os = osx ]
then
    install_osx_tools
elif [ $os = aix ]
then
    install_aix_tools
elif [ $os = solaris ]
then
    install_solaris_tools
elif [ $os = mandrake ]
then
    install_mandrake_tools
elif [ $os = suse ]
then
    install_suse_tools
elif [ $os = redhat ]
then
    install_redhat_tools
elif [ $os = gentoo ]
then
    install_gentoo_tools
elif [ $os = arch ]
then
    install_arch_tools
elif [ $os = slackware ]
then
    sudo=""
    install_slackware_tools
fi

get_and_build_ebe
