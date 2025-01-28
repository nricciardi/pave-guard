import { Module } from '@nestjs/common';
import { ModelService } from './services/model/model.service';
import { UtilitiesService } from './services/utilities/utilities.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Prediction, PredictionSchema } from './models/prediction.model';
import { ModelProxyResolver } from './resolvers/model-proxy.resolver';
import { UserModule } from '../user/user.module';

@Module({
  providers: [
    ModelService,
    UtilitiesService,

    ModelProxyResolver
  ],
  imports: [
    MongooseModule.forFeature([
      {
          name: Prediction.name,
          schema: PredictionSchema
      },
    ]),
    UserModule
  ]
})
export class ModelModule {}
