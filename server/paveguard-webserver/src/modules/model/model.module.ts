import { Module } from '@nestjs/common';
import { ModelService } from './services/model/model.service';

@Module({
  providers: [ModelService]
})
export class ModelModule {}
