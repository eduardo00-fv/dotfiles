// SDDM "Tinta" — mismo diseño editorial que hyprlock (marco, reloj delgado,
// frase de Thrain en Fraunces) más lo propio del login: usuario, sesión y apagado.
import QtQuick 2.15
import "Frases.js" as Frases

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#1d1a16"

    readonly property real s: height / 1080          // escala respecto a 1080p
    readonly property color crema: "#ecdcc0"
    readonly property color arena: "#bfae90"
    readonly property color pardo: "#8a7d6b"
    readonly property color nogal: "#5e5245"
    readonly property color terracota: "#e0551f"
    readonly property color ocre: "#d9a441"
    readonly property color ladrillo: "#b83a2e"
    readonly property string mono: "CaskaydiaCove Nerd Font"

    property int usuario: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sesion: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string nombreUsuario: ""
    property bool fallo: false

    // nombres desde los modelos (no exponen .get(): se leen con un Repeater oculto)
    Repeater { id: usuarios; model: userModel; delegate: Item { property string nombre: model.name } }
    Repeater { id: sesiones; model: sessionModel; delegate: Item { property string nombre: model.name } }
    // `n` (= rep.count) solo está para que la vinculación se reevalúe cuando el Repeater se llena
    function nombreDe(rep, i, n) { var it = n > 0 ? rep.itemAt(i) : null; return it ? it.nombre : "" }

    // ------------------------------------------------------------ fondo
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
    }
    Rectangle { anchors.fill: parent; color: "#1d1a16"; opacity: 0.25 }

    // ------------------------------------------------------------ marco
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 80 * s
        height: parent.height - 80 * s
        color: "transparent"
        border.width: 1
        border.color: "#2eecdcc0"
    }

    component Esquina: Text {
        color: "#ccbfae90"
        font.family: root.mono
        font.pixelSize: 13 * root.s
        font.letterSpacing: 4 * root.s
    }

    Esquina { text: "THRAIN"; x: 72 * s; y: 64 * s - height / 2 }
    Esquina { text: "INICIAR SESIÓN"; color: "#a0bfae90"; anchors.right: parent.right; anchors.rightMargin: 72 * s; y: 64 * s - height / 2 }
    Esquina { text: "ARCH LINUX"; color: "#78bfae90"; x: 72 * s; y: parent.height - 64 * s - height / 2 }

    // sesión (abajo a la derecha): clic para cambiar
    Esquina {
        id: textoSesion
        text: "SESIÓN  " + nombreDe(sesiones, root.sesion, sesiones.count).toUpperCase() + "  ▾"
        color: areaSesion.containsMouse ? root.terracota : "#aabfae90"
        anchors.right: parent.right; anchors.rightMargin: 72 * s
        y: parent.height - 64 * s - height / 2
        Behavior on color { ColorAnimation { duration: 160 } }
        MouseArea {
            id: areaSesion
            anchors.fill: parent; anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sesion = (root.sesion + 1) % Math.max(1, sesiones.count)
        }
    }

    // apagado (abajo al centro)
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - 64 * s - height / 2
        spacing: 34 * s
        Repeater {
            model: [
                { t: "SUSPENDER", ok: sddm.canSuspend, f: function () { sddm.suspend() } },
                { t: "REINICIAR", ok: sddm.canReboot,  f: function () { sddm.reboot() } },
                { t: "APAGAR",    ok: sddm.canPowerOff, f: function () { sddm.powerOff() } }
            ]
            delegate: Esquina {
                visible: modelData.ok
                text: modelData.t
                color: area.containsMouse ? root.terracota : "#78bfae90"
                Behavior on color { ColorAnimation { duration: 160 } }
                MouseArea {
                    id: area
                    anchors.fill: parent; anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.f()
                }
            }
        }
    }

    // ------------------------------------------------------------ reloj, fecha, línea, frase
    readonly property var dias: ["DOMINGO", "LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES", "SÁBADO"]
    readonly property var meses: ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO",
                                  "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    property date ahora: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.ahora = new Date() }

    Text {
        id: reloj
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 - 210 * s - height / 2
        text: Qt.formatTime(root.ahora, "HH:mm")
        color: "#f2ecdcc0"
        font.family: root.mono
        font.weight: Font.Light
        font.pixelSize: 122 * s
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 - 120 * s - height / 2
        text: root.dias[root.ahora.getDay()] + " · " + root.ahora.getDate() + " DE " + root.meses[root.ahora.getMonth()]
        color: "#d2e2cda8"
        font.family: root.mono
        font.pixelSize: 15 * s
        font.letterSpacing: 5 * s
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 - 61 * s - 1
        width: 48 * s; height: 2
        color: "#e6e0551f"
    }
    Text {
        id: frase
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(implicitWidth, parent.width * 0.7)
        y: parent.height / 2 - height / 2
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: "“" + Frases.lista[Math.floor(Math.random() * Frases.lista.length)] + "”"
        color: "#ebecdcc0"
        font.family: "Fraunces"
        font.pixelSize: 28 * s
        font.variableAxes: { "wght": 330, "SOFT": 100 }
    }

    // ------------------------------------------------------------ usuario + contraseña
    Column {
        id: acceso
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 2 + 92 * s
        spacing: 12 * s

        // usuario: clic para cambiar si hay más de uno
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: nombreDe(usuarios, root.usuario, usuarios.count) + (usuarios.count > 1 ? "  ▾" : "")
            color: areaUsuario.containsMouse ? root.terracota : root.arena
            font.family: root.mono
            font.pixelSize: 14 * s
            font.letterSpacing: 3 * s
            Behavior on color { ColorAnimation { duration: 160 } }
            MouseArea {
                id: areaUsuario
                anchors.fill: parent; anchors.margins: -8
                hoverEnabled: usuarios.count > 1
                enabled: usuarios.count > 1
                onClicked: root.usuario = (root.usuario + 1) % usuarios.count
            }
        }

        Rectangle {
            id: caja
            width: 280 * s; height: 46 * s
            radius: 12 * s
            color: "#cc1d1a16"
            border.width: 1
            border.color: root.fallo ? root.ladrillo : (clave.activeFocus ? "#cce0551f" : "#cc5e5245")
            Behavior on border.color { ColorAnimation { duration: 200 } }

            TextInput {
                id: clave
                anchors.fill: parent
                anchors.leftMargin: 18 * s; anchors.rightMargin: 18 * s
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                color: root.crema
                selectionColor: root.terracota
                font.family: root.mono
                font.pixelSize: 15 * s
                font.letterSpacing: 4 * s
                focus: true
                clip: true
                onTextChanged: root.fallo = false
                onAccepted: {
                    if (text.length === 0) return
                    sddm.login(nombreDe(usuarios, root.usuario, usuarios.count), text, root.sesion)
                }
                Keys.onEscapePressed: text = ""
            }
            Text {
                anchors.centerIn: parent
                visible: clave.text.length === 0
                text: root.fallo ? "contraseña incorrecta" : "contraseña"
                color: root.fallo ? root.ladrillo : root.pardo
                font.family: root.mono
                font.pixelSize: 14 * s
            }
            // sacudida al fallar
            SequentialAnimation {
                id: sacudida
                NumberAnimation { target: caja; property: "x"; to: -10 * root.s; duration: 50 }
                NumberAnimation { target: caja; property: "x"; to:  10 * root.s; duration: 70 }
                NumberAnimation { target: caja; property: "x"; to:  -6 * root.s; duration: 60 }
                NumberAnimation { target: caja; property: "x"; to:   0; duration: 50 }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "mayúsculas activadas"
            color: root.ocre
            opacity: keyboard.capsLock ? 1 : 0
            font.family: root.mono
            font.pixelSize: 12 * s
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.fallo = true
            clave.text = ""
            sacudida.start()
            clave.forceActiveFocus()
        }
    }

    // entrada suave
    opacity: 0
    Component.onCompleted: {
        opacity = 1
        clave.forceActiveFocus()
        // sin sesión recordada: Hyprland por defecto
        if (sessionModel.lastIndex < 0)
            for (var i = 0; i < sesiones.count; i++)
                if (nombreDe(sesiones, i, sesiones.count) === "Hyprland") { root.sesion = i; break }
    }
    Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
}
