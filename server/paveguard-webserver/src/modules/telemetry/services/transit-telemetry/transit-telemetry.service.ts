import { Injectable } from '@nestjs/common';
import { TransitTelemetry } from '../../models/transit-telemetry.model';
import { CreateTransitTelemetryDto } from '../../dto/create-transit-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class TrafficTelemetryService {
    constructor(private telemetryService: TelemetryService, @InjectModel(TransitTelemetry.name) private trafficTelemetryModel: Model<TransitTelemetry>) {
    }

    async findAll(): Promise<TransitTelemetry[]> {
        return this.trafficTelemetryModel.find().exec()
    }

    async create(data: CreateTransitTelemetryDto): Promise<TransitTelemetry> {
        return this.trafficTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}
