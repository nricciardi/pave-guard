import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Telemetry } from '../../models/telemetry.model';
import { StaticGuardService } from 'src/modules/device/services/static-guard/static-guard.service';
import { CreateDynamicTelemetryDto, TelemetryFilters } from '../../dto/create-telemetry.dto';
import { LocationDto } from '../../dto/location.dto';


export interface TelemetryCrud<T, C> {
    findAll(filters?: TelemetryFilters): Promise<T[]>;

    create(data: C): Promise<T>;
}



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

    buildQuery(filters: TelemetryFilters) {
        const query: Record<string, any> = {};

        if (filters.deviceId)
            query['metadata.deviceId'] = filters.deviceId;
        
        if (filters.road)
            query['metadata.road'] = filters.road;
        
        if (filters.city)
            query['metadata.city'] = filters.city;
        
        if (filters.county)
            query['metadata.county'] = filters.county;
        
        if (filters.state)
            query['metadata.state'] = filters.state;
        

        if (filters.from || filters.to) {
            query.timestamp = {};

            if (filters.from)
                query.timestamp.$gte = new Date(filters.from);
            
            if (filters.to)
                query.timestamp.$lte = new Date(filters.to);
        }

        return query;
    }
}
