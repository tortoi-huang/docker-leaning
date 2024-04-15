package org.huang.dockerweb.dockerweb;

import java.util.Date;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@SpringBootApplication
public class DockerwebApplication {

	public static void main(String[] args) {
		SpringApplication.run(DockerwebApplication.class, args);
	}

	@Controller
	class IndexController{
		@GetMapping("/")
		@ResponseBody
		public String index() {
			return "hello today is" + new Date();
		}
	}
}
