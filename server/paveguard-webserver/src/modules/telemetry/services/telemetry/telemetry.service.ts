import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Telemetry } from '../../models/telemetry.model';
import { IsDate, IsLatitude, IsLongitude, IsMongoId, IsNotEmpty, IsString, ValidateNested } from 'class-validator';



export class MetadataCreateInput {
  @IsString()
  @IsMongoId()
  deviceId: string;

  @IsString()
  road: string;
}

export class TelemetryCreateInput {
  
  @ValidateNested()
  metadata: MetadataCreateInput;

  @IsDate()
  @IsNotEmpty()
  timestamp: string;

  @IsLatitude()
  @IsNotEmpty()
  latitude: number;

  @IsLongitude()
  @IsNotEmpty()
  longitude: number;
}


@Injectable()
export class TelemetryService {

    constructor(@InjectModel(Telemetry.name) private telemetryModel: Model<Telemetry>) {
    }

    async findAll(): Promise<Telemetry[]> {
        return this.telemetryModel.find().exec();
    }
}
