import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Prediction } from '../../models/prediction.model';

@Injectable()
export class ModelService {

    constructor(
        private readonly configService: ConfigService,
        @InjectModel(Prediction.name) private predictionModel: Model<Prediction>
    ) {}

  async predictions(): Promise<Prediction[]> {
    return this.predictionModel.find().exec();
  }
}
