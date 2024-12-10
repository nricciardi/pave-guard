import { Injectable } from '@nestjs/common';
import { RoadCrackTelemetry } from '../../models/road-crack-telemetry.model';
import { CreateRoadCrackTelemetryDto } from '../../dto/create-road-crack-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class RoadCrackService {
    constructor(@InjectModel(RoadCrackTelemetry.name) private roadCrackTelemetryModel: Model<RoadCrackTelemetry>) {
    }

    async findAll(): Promise<RoadCrackTelemetry[]> {
        return this.roadCrackTelemetryModel.find().exec()
    }

    async create(data: RoadCrackTelemetry): Promise<RoadCrackTelemetry> {
        return this.roadCrackTelemetryModel.create(data);
    }
}
