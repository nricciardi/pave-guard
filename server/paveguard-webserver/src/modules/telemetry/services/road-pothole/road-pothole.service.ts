import { Injectable } from '@nestjs/common';
import { RoadPotholeTelemetry } from '../../models/road-pothole-telemetry.model';
import { CreateRoadPotholeTelemetryDto } from '../../dto/create-road-pothole-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';
import { TelemetryFilters } from '../../dto/create-telemetry.dto';

@Injectable()
export class RoadPotholeService {
    constructor(private telemetryService: TelemetryService, @InjectModel(RoadPotholeTelemetry.name) private roadPotholeTelemetryModel: Model<RoadPotholeTelemetry>) {
    }

    async findAll(filters?: TelemetryFilters): Promise<RoadPotholeTelemetry[]> {
        return this.roadPotholeTelemetryModel.find(this.telemetryService.buildQuery(filters)).exec()
    }

    async create(data: CreateRoadPotholeTelemetryDto): Promise<RoadPotholeTelemetry> {
        return this.roadPotholeTelemetryModel.create({
            ...this.telemetryService.buildDynamicMetadata(data),
            ...data
        });
    }
}
