import { Resolver, Query, Field, ID, ObjectType, ArgsType, InputType } from '@nestjs/graphql';
import { TelemetryService } from '../services/telemetry/telemetry.service';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { IsString, IsMongoId, IsNotEmpty, ValidateNested, IsDate, IsLatitude, IsLongitude } from 'class-validator';

@ObjectType()
export class TelemetryQuery {
  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: Date;

  @Field()
  latitude: number;

  @Field()
  longitude: number;
}


@ArgsType()
export class TelemetryCreateMutation {
  
  @Field()
  @IsString()
  @IsMongoId()
  deviceId: string;

  @Field()
  @IsDate()
  @IsNotEmpty()
  timestamp: string;

  @Field()
  @IsLatitude()
  @IsNotEmpty()
  latitude: number;

  @Field()
  @IsLongitude()
  @IsNotEmpty()
  longitude: number;
}

@Resolver(() => TelemetryQuery)
export class TelemetryResolver {
  constructor(
    private readonly telemetryService: TelemetryService,
  ) {}

  @Query(() => [TelemetryQuery])
  @UseGuards(AdminGuard)
  async telemetries() {
    return this.telemetryService.findAll();
  }
}
