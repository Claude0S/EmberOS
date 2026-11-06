// Ember OS — слайды во время установки
import QtQuick
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function nextSlide() { presentation.goToNextSlide() }

    Timer {
        interval: 7000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    component EmberSlide: Slide {
        property string title
        property string body
        Rectangle { anchors.fill: parent; color: "#1a1320" }
        Image {
            anchors.fill: parent
            source: "slide-bg.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.55
        }
        Column {
            anchors.centerIn: parent
            width: parent.width * 0.8
            spacing: 18
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "logo.png"
                width: 96; height: 96
                smooth: false
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: title
                color: "#f3a46c"
                font.pixelSize: 30
                font.bold: true
                wrapMode: Text.WordWrap
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: body
                color: "#fbeee0"
                font.pixelSize: 17
                wrapMode: Text.WordWrap
            }
        }
    }

    EmberSlide {
        title: "Ласкаво просимо до Ember OS"
        body: "Тепла, гарна й легка система. Встановлення займе кілька хвилин — саме час для чаю ☕\n\nWelcome to Ember OS — this takes a few minutes."
    }
    EmberSlide {
        title: "Win + Enter — командний рядок"
        body: "/search котики — пошук у Firefox\n/download steam — встановити програму\n/little — легкий режим для старих компʼютерів"
    }
    EmberSlide {
        title: "Ігри та програми Windows"
        body: "Steam, Wine і Hydra Launcher самі докачаються після першого запуску. Файли .exe відкриваються подвійним кліком."
    }
    EmberSlide {
        title: "Драйвери — автоматично"
        body: "Система сама визначає відеокарту, Wi-Fi, звук і ставить потрібні драйвери. Нове залізо теж підхопить."
    }
    EmberSlide {
        title: "Віджети"
        body: "Музика, годинник, погода й стан системи просто на робочому столі. Перетягуй мишкою, налаштовуй через /widgets."
    }

    function onActivate() { presentation.currentSlide = 0 }
    function onLeave() { }
}
