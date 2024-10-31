import { Injectable, Logger, NestMiddleware } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {

  private readonly logger = new Logger(LoggerMiddleware.name);

  constructor(
    private readonly configService: ConfigService,
  ) {}

  use(req: Request, res: Response, next: () => void) {

    if(this.configService.get("DEBUG") === 'true') {

      this.logger.debug("Request:");
      console.log(req.headers);
      console.log(req.body);      
    }

    next();
  }
}
