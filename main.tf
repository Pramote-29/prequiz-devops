
terraform { 
  required_providers { 
    docker = { 
      source  = "kreuzwerker/docker" 
      version = "3.0.2" 
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    } 
  } 
} 

provider "docker" { 
  host = "unix:///var/run/docker.sock"
}

resource "null_resource" "execute_script" {
  provisioner "local-exec" {
    command = "pwsh ./buildImg.ps1"
    working_dir = "${path.module}"
  }
}

resource "docker_image" "my_app" {
  name = "node-express-app:latest"
  depends_on = [null_resource.execute_script]
}

resource "docker_container" "my_container" {
  name = "my-express-app"
  image = docker_image.my_app.name
  ports {
    internal = 3002
    external = 80
  }
}
