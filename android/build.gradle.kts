allprojects {
    repositories {
        maven("https://maven.aliyun.com/repository/public")
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/gradle-plugin")
        maven("https://storage.flutter-io.cn/download.flutter.io")
        maven("https://mirror.sjtu.edu.cn/google-flutter")
        google()
        mavenCentral()
        
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Skip buildDir redirection for pub-cache plugins on a different drive,
    // otherwise Gradle fails with "different roots" when resolving relative paths.
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    val sameRoot = newSubprojectBuildDir.asFile.absolutePath.take(2)
        .equals(project.projectDir.absolutePath.take(2), ignoreCase = true)
    if (sameRoot) {
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
