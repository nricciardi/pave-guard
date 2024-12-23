import { Resolver, Query, Field, ID, ObjectType, InputType } from '@nestjs/graphql';
import { TelemetryService } from '../services/telemetry/telemetry.service';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { LocationDto } from '../dto/location.dto';


@ObjectType()
export class MetadataQuery extends LocationDto {
  @Field()
  deviceId: string;

}

@ObjectType()
export class TelemetryQuery {
  @Field(() => ID)
  id: string;

  @Field()
  metadata: MetadataQuery;

  @Field()
  timestamp: Date;

  @Field()
  latitude: number;

  @Field()
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

  @Query(() => [LocationDto])
  @UseGuards(AdminGuard)
  async locations() {
    return this.telemetryService.mappedLocations();
  }
}
