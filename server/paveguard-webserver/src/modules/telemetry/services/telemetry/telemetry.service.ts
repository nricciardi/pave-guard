import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Telemetry } from '../../models/telemetry.model';
import { StaticGuardService } from 'src/modules/device/services/static-guard/static-guard.service';
import { CreateDynamicTelemetryDto } from '../../dto/create-telemetry.dto';
import { LocationDto } from '../../dto/location.dto';

@Injectable()
export class TelemetryService {

    constructor(private deviceService: StaticGuardService, @InjectModel(Telemetry.name) private telemetryModel: Model<Telemetry>) {
    }

    async findAll(): Promise<Telemetry[]> {
        return this.telemetryModel.find().exec();
    }

    async mappedLocations(): Promise<LocationDto[]> {
        return this.telemetryModel.aggregate([
            {
                $project: {
                    "metadata.road": 1,
                    "metadata.city": 1,
                    "metadata.county": { $ifNull: ["$metadata.county", "Unknown"] },
                    "metadata.state": 1,
                }
            },
            {
                $group: {
                  _id: {
                    road: '$metadata.road',
                    city: '$metadata.city',
                    county: '$metadata.county',
                    state: '$metadata.state',
                  },
                },
              },
              {
                $replaceRoot: {
                  newRoot: '$_id',
                },
              },
        ])
    }

    async buildStaticFieldsByDeviceId(deviceId: string): Promise<object> {

        const device = await this.deviceService.findById(deviceId);

        return {
            metadata: {
                deviceId: deviceId,
                road: device.road,
                city: device.city,
                county: device.county,
                state: device.state
            },
            latitude: device.latitude,
            longitude: device.longitude,
        }   
    }

    buildDynamicMetadata(data: CreateDynamicTelemetryDto): object {
        return {
            metadata: {
                deviceId: data.deviceId,
                road: data.road,
                city: data.city,
                county: data.county,
                state: data.state
            }
        }
    }
}
