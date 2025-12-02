buildscript {
    // ... otros bloques
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0") // Ejemplo de versión de Android Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22") // Ejemplo de versión de Kotlin
        // ... otras dependencias
        // 🚨 AGREGA ESTA LÍNEA DENTRO DEL BLOQUE dependencies:
        classpath("com.google.gms:google-services:4.4.1") // <-- ¡IMPORTANTE!
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
