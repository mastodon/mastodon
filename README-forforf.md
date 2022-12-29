
## Local Installation

Random stuff
* Generally followed the mastodon [development guide](https://github.com/spinda/mastodon-documentation/blob/d17b64e1300b162e422d0026c8b5474128471566/Running-Mastodon/Development-guide.md), but there are many similar guides that all seem to be slightly different. Use your best judgement.
* I used brew for postgres

### Issues
* blurhash
  * encode.bundle not found -> Fix: symbolic link from where it was located (I belive it was in ./lib, rut was being looked for in ./ext perhaps it was vice versa)
* ox
  * ox/ox not found -> Fix: symbolic link the `ox.rb` file that was in the parent director from the `ox/` directory. 

## Docker Installation

I followed the [docker guide](https://github.com/spinda/mastodon-documentation/blob/d17b64e1300b162e422d0026c8b5474128471566/Running-Mastodon/Docker-Guide.md)

### Issues
* It's `docker compose` now, not `docker-compose`
* In order to set up production env, I had to tweak a few things
  * Use `host.docker.internal` rather than `localhost` to connect to the host db
* To access it locally, 
  * I had to add localhost to `config.hosts = ['localhost']`
  * I had to force ssl to false
  * Note: These were reverted when building the deployment image

### Pushing docker image to ECR
Generally followed [Ivan Polovyi's Guide](https://aws.plainenglish.io/how-to-push-an-image-to-aws-ecr-b2be848c2ef)

* Rename the build image
`docker image tag forforf/mastodon:latest 438378517892.dkr.ecr.us-east-2.amazonaws.com/mastodon:latest`
* If the docker file is arm64 (default if built on Mac M1). Then set the architecture in the task defintion.
The only way I've found so far is to modify `runtimePlatform` in the task definition JSON:
```JSON
{
  "...": "other stuff",
  "memory": "512",
  "runtimePlatform": {
    "operatingSystemFamily": "LINUX",
    "cpuArchitecture": "ARM64"
  },
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "....": "other stuff"
}
```

## Development/Deployment Process

### Develop and Deploy the image to ECR Repo
1. Standard rails development to change the code locally
2. Run `docker compose build` which used `docker-compose.yml` to create the image `forforf/mastodon`
3. Rename the image for the ECR repo: `docker image tag forforf/mastodon:latest 438378517892.dkr.ecr.us-east-2.amazonaws.com/mastodon:latest`
4. Push the image to ECR: `docker image push 438378517892.dkr.ecr.us-east-2.amazonaws.com/mastodo`. Note: This may require logging in to the ECR repo first.

### Update the ECS Service to use the new ECR image
1. Go to Task Definitions and Click on the task definition to update
2. Click on `Create new revision`
3. Scroll down to the `Image` and make sure it is the desired docker image to use. If it needs updating, click on the container name to bring up the form for updating it.
3. Clicking on the container name is also where you can update environment variables. Though it would be better to update the Cloudformation source rather than here.
4. Click `Update` to apply the changes
5. IMPORTANT: Go to `Configure via JSON` and make sure the "runtimePlatform" setting matches that of the docker image. Usually `"cpuArchitectrure=ARM64"` for M1 created images
6. Click on `Create` to create the task 
7. Wait for Status to be `ACTIVE`
8. Select the task and in `Actions` choose `Update Service`
9. IMPORTANT: Make sure the Service Name selection matches the desired service to update.
9. Check `Force new deployment` if this task should take over from the old one (this is usually the case)
10. Click `Next` for the remaining pages, on final page click `Update Service`
11. There should be a success message and an option to go to the service. Click to go to the service.
12. Note: Not sure what happens if `Force new deployment` was chosen, but should be a subset of the below.
13. If you go to the service view right away, there should be two deployments, one with status "PRIMARY" and one with "ACTIVE". The "PRIMARY" deployment will initially have a `Rollout state` of "In progress"
14. The "ACTIVE" deployment will change to "DRAINING" when the new deployment is ready to be deployed.
15. Finally, there will be a single item with status "PRIMARY" once the new deployment completes (`Rollout state`: "Completed")
16. Click on `Tasks` tab. The Running Task Definition should match the one that was just created.


      
