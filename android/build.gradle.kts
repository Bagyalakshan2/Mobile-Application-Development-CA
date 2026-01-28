// android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
   
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
