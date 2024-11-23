import { Injectable } from '@nestjs/common';
import { TrafficTelemetry } from '../../models/traffic-telemetry.model';
import { CreateTrafficTelemetryDto } from '../../dto/create-traffic-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class TrafficTelemetryService {
    constructor(@InjectModel(TrafficTelemetry.name) private trafficTelemetryModel: Model<TrafficTelemetry>) {
    }

    async findAll(): Promise<TrafficTelemetry[]> {
        return this.trafficTelemetryModel.find().exec()
    }

    async create(data: CreateTrafficTelemetryDto): Promise<TrafficTelemetry> {

        console.log("create");
        
        console.log(data);
        

        return this.trafficTelemetryModel.create({ ...data });
    }
}
