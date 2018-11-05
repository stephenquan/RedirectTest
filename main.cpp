#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "Networking/Networking.h"
#include "Engine/Engine.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    const char* uri = "SQ";
    int versionMajor = 1;
    int versionMinor = 0;
    Networking::registerTypes(uri, versionMajor, versionMinor);
    Engine::registerTypes(uri, versionMajor, versionMinor);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
