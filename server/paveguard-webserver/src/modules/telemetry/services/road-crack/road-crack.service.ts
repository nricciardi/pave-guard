import { Injectable } from '@nestjs/common';
import { RoadCrackTelemetry } from '../../models/road-crack-telemetry.model';
import { CreateRoadCrackTelemetryDto } from '../../dto/create-road-crack-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';
import { TelemetryFilters } from '../../dto/create-telemetry.dto';

@Injectable()
export class RoadCrackService {
    constructor(private telemetryService: TelemetryService, @InjectModel(RoadCrackTelemetry.name) private roadCrackTelemetryModel: Model<RoadCrackTelemetry>) {
    }

    async findAll(filters?: TelemetryFilters): Promise<RoadCrackTelemetry[]> {
        return this.roadCrackTelemetryModel.find(this.telemetryService.buildQuery(filters)).exec()
    }

    async create(data: CreateRoadCrackTelemetryDto): Promise<RoadCrackTelemetry> {
        return this.roadCrackTelemetryModel.create({
            ...this.telemetryService.buildDynamicMetadata(data),
            ...data
        });
    }
}
