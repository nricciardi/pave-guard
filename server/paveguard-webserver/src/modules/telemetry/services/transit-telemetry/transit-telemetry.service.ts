import { Injectable } from '@nestjs/common';
import { TransitTelemetry } from '../../models/transit-telemetry.model';
import { CreateTransitTelemetryDto } from '../../dto/create-transit-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';
import { TelemetryFilters } from '../../dto/create-telemetry.dto';

@Injectable()
export class TrafficTelemetryService {
    constructor(private telemetryService: TelemetryService, @InjectModel(TransitTelemetry.name) private trafficTelemetryModel: Model<TransitTelemetry>) {
    }

    async findAll(filters?: TelemetryFilters): Promise<TransitTelemetry[]> {
        return this.trafficTelemetryModel.find(this.telemetryService.buildQuery(filters)).exec()
    }

    async create(data: CreateTransitTelemetryDto): Promise<TransitTelemetry> {
        return this.trafficTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}
