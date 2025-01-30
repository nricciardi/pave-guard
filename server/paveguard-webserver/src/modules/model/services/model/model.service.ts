import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Prediction } from '../../models/prediction.model';
import { PredictionDto } from '../../dto/prediction.dto';

@Injectable()
export class ModelService {

    constructor(
        private readonly configService: ConfigService,
        @InjectModel(Prediction.name) private predictionModel: Model<Prediction>
    ) {}

  async predictions(): Promise<Prediction[]> {
    return this.predictionModel.find().exec();
  }

  async createPrediction(input: PredictionDto): Promise<Prediction> {
    
    const filter = {
      road: input.road,
      city: input.city,
      county: input.county,
      state: input.state,
    };

    this.predictionModel.replaceOne(filter, input, {
      upsert: true,
    }).exec();

    return this.predictionModel.findOne(filter);
  }
}
