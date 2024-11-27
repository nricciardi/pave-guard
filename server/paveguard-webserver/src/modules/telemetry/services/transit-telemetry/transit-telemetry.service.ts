import { Injectable } from '@nestjs/common';
import { TransitTelemetry } from '../../models/transit-telemetry.model';
import { CreateTransitTelemetryDto } from '../../dto/create-transit-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class TrafficTelemetryService {
    constructor(@InjectModel(TransitTelemetry.name) private trafficTelemetryModel: Model<TransitTelemetry>) {
    }

    async findAll(): Promise<TransitTelemetry[]> {
        return this.trafficTelemetryModel.find().exec()
    }

    async create(data: CreateTransitTelemetryDto): Promise<TransitTelemetry> {
        return this.trafficTelemetryModel.create({ ...data });
    }
}
