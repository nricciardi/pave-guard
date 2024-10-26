import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  let port = /* process.env.PORT ??  */3000;
  
  console.log(`listen on... ${port}`);
  
  await app.listen(port);
}
bootstrap();
