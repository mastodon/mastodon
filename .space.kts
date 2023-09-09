/**
 * JetBrains Space Automation
 * This Kotlin-script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build and push Docker") {
  host("Build artifacts and a Docker image") {
    // generate artifacts required for the image
    //shellScript {
    //    content = """
    //        ./generateArtifacts.sh
    //    """
    //}

    dockerBuildPush {
      // Docker context, by default, project root
      // context = "docker"
      // path to Dockerfile relative to project root
      // if 'file' is not specified, Docker will look for it in 'context'/Dockerfile
      file = "Dockerfile"
      //labels["vendor"] = "mycompany"

      val spaceRepo = "clusterjan.registry.jetbrains.space/p/main/containers/mastodon"
      // image tags for 'docker push'
      tags {
        +"$spaceRepo:v4.2.0-beta3-clusterjan"
        +"$spaceRepo:latest"
      }
    }
  }
}
