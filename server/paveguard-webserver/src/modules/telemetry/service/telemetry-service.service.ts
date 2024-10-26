import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Telemetry } from '../model/telemetry-schema.model';

@Injectable()
export class TelemetryService {

    constructor(@InjectModel(Telemetry.name) private telemetryModel: Model<Telemetry>) {
    }

    async findAll(): Promise<Telemetry[]> {
        return this.telemetryModel.find().exec();
    }
}
