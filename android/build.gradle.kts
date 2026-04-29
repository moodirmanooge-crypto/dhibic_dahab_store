buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Waxaan ku daray xariiqyadan si plugins-ka ay u shaqeeyaan
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
        classpath("com.google.gms:google-services:4.4.0") // Firebase haddii aad isticmaalayso
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Qaybtan waxba kama beddelin, waa habka Flutter u maamulo build directory-ga
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