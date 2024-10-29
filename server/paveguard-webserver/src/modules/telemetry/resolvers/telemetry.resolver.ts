import { Resolver, Query, Field, ID, ObjectType } from '@nestjs/graphql';
import { TelemetryService } from '../service/telemetry/telemetry.service';

@ObjectType()
export class TelemetryQuery {
  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: number;
}

@Resolver(() => TelemetryQuery)
export class TelemetryResolver {
  constructor(
    private readonly telemetryService: TelemetryService,
  ) {}

  @Query(() => [TelemetryQuery])
  async telemetries() {
    return this.telemetryService.findAll();
  }
}
