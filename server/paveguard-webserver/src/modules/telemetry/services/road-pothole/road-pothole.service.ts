import { Injectable } from '@nestjs/common';
import { RoadPotholeTelemetry } from '../../models/road-pothole-telemetry.model';
import { CreateRoadPotholeTelemetryDto } from '../../dto/create-road-pothole-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class RoadPotholeService {
    constructor(@InjectModel(RoadPotholeTelemetry.name) private roadPotholeTelemetryModel: Model<RoadPotholeTelemetry>) {
    }

    async findAll(): Promise<RoadPotholeTelemetry[]> {
        return this.roadPotholeTelemetryModel.find().exec()
    }

    async create(data: CreateRoadPotholeTelemetryDto): Promise<RoadPotholeTelemetry> {
        return this.roadPotholeTelemetryModel.create({
            metadata: {
                deviceId: data.deviceId,
                road: data.road
            },
            ...data
        });
    }
}
